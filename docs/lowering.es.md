# Lowering

Toda construcción PolyModelica se reescribe a Modelica estándar **en tiempo
de parseo**, antes de que corra cualquier otra etapa del compilador. Esta
página documenta el contrato: en qué se convierte cada construcción.

## Dónde ocurre

Con `--grammar=PolyModelica`, el parser le pasa el programa recién parseado
a un paso de elaboración (`PolyModelicaElaboration.elaborate()`) que
devuelve Modelica 100% vainilla. La symbol table del compilador solo guarda
el programa loweado, lo que tiene dos consecuencias prácticas:

- `list(Modelo)` y `listFile(Modelo)` — y el **View Lowered Modelica** de
  OMEdit — muestran el código loweado, haciendo todo el dialecto
  inspeccionable.
- Todo lo que está después del parser (flattening, solvers, export FMI,
  ploteo) es OpenModelica de fábrica y no necesita cambios.

El único chequeo consciente de PolyModelica fuera del parser es un chequeo
nominal de subtipos en el front end nuevo, que rechaza sub-arrays de
polyvector cuyo tipo no deriva del tipo base.

## Declaraciones

Un array común por sub-array, con nombre
`<base>_<polyvector>_<subtipo>` (todo en minúsculas), etiquetado con una
annotation que registra su origen:

```modelica
polyvector Base[5] v = {A[3], B[2]};
// se convierte en:
A base_v_a[3] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
B base_v_b[2] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
```

Los elementos conservan su orden de declaración: los índices lógicos 1–3
viven en `base_v_a`, los índices 4–5 en `base_v_b`. Todas las demás
reescrituras son contabilidad sobre esta disposición: un índice lógico se
resuelve a *(sub-array, offset local)*.

## Construcción por construcción

| PolyModelica | Se lowea a |
| --- | --- |
| `polyvector Base[5] v = {A[3], B[2]}` | un array anotado por sub-array |
| `v[4].x` | `base_v_b[1].x` (índice resuelto estáticamente) |
| `v.x` | `cat(1, base_v_a.x, base_v_b.x)` |
| `v[1:3].y` (LHS, RHS literal) | una ecuación partida por sub-array |
| `v[2:4].y = u` (RHS no literal) | `cat(1, base_v_a[2:3].y, base_v_b[1:1].y) = u` |
| `for s in v loop … end for` | un loop por sub-array, rango local `1:n`, offsets sumados a los otros subíndices |
| `for i in 1:5 … v[i]` | rango partido en los bordes, límites globales conservados, `base_v_b[i - 3]` |
| `{e(s) for s in v}` | literal de array desenrollado, un término por elemento |
| `s is A` / `isType` / `isSubtype` | plegado a `true`/`false` por sub-array; solo se emiten las ramas vivas |
| `match s case …` | selección por sub-array del primer case que matchea |
| `size(v)`, `ndims(v)`, `numTypes(v)` | constantes enteras |
| `connect(c, v[1:4].p)` | un `connect` por sub-array con rangos correspondientes |

Vale la pena contrastar las dos estrategias de iteración:

```modelica
// for s in v          → rangos locales, offset en los OTROS arrays:
for s in 1:2 loop
  w[3 + s] = base_v_b[s].x;
end for;

// for i in 1:5, v[i]  → rangos globales, offset en el acceso al POLYVECTOR:
for i in 4:5 loop
  w[i] = base_v_b[i - 3].x;
end for;
```

## El despacho se compila y desaparece

Los predicados de tipo y `match` nunca sobreviven hasta el runtime. El
compilador conoce el tipo concreto de cada elemento por sub-array, evalúa
cada predicado a una constante y emite solo la rama sobreviviente dentro del
loop de cada sub-array:

```modelica
for s in v loop
  if s is A then w[s] = 2.0; else w[s] = 1.0; end if;
end for;
// se convierte en:
for s in 1:3 loop  w[s] = 2.0;     end for;   // tramo A
for s in 1:2 loop  w[3 + s] = 1.0; end for;   // tramo B
```

No hay tag de tipo en runtime, ni costo de branching, ni código muerto en el
modelo loweado.

## Verlo con tus propios ojos

Desde un script `.mos`:

```modelica
setCommandLineOptions("--grammar=PolyModelica"); getErrorString();
loadFile("MiModelo.mo"); getErrorString();
list(MiModelo); getErrorString();
```

En OMEdit: click derecho en la clase → **View Lowered Modelica**. Cada
pestaña "Modelica loweado" de esta documentación se produjo exactamente así.
