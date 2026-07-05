# Indexar un elemento

Acceder a un elemento por su posición lógica, con su tipo **concreto** — así
los campos que solo existen en el subtipo son accesibles. Funciona a ambos
lados de una ecuación.

## Sintaxis

```modelica
v[i].campo         // i: literal, parameter/constant, o expresión sobre ellos
v[end].campo       // último elemento
```

## Ejemplo

=== "PolyModelica"

    ```modelica
    --8<-- "AccessIndex.mo"
    ```

=== "Modelica loweado"

    ```modelica
    parameter Integer k = 2;
    Real r1, r2, r3, r4;
    equation
      r1 = base_v_a[2].x;
      r2 = base_v_b[1].x;
      r3 = base_v_b[2].x;
      r4 = base_v_a[1].x - base_v_b[1].z;
    ```

El compilador resuelve cada índice lógico a un sub-array y offset local en
tiempo de elaboración — `v[4]` sobre `{A[3], B[2]}` se convierte en
`base_v_b[1]`.

## Reglas

- El índice debe ser **resoluble en la elaboración**: un literal entero, un
  `parameter`/`constant`, o una expresión sobre ellos. `+`, `-`, `*` y `/`
  entera se pliegan; `end` también funciona.
- Los límites se chequean en tiempo de compilación; un literal fuera de
  rango es un error.
- Un índice que recién se conoce en runtime se rechaza:

```modelica
Integer k;
equation
  k = 1;
  r = v[k].x;   // Error: el índice debe resolverse en la elaboración
```

El mensaje de error nombra las alternativas para acceso dinámico: iterar con
`for s in v loop` ([Iterar](iterate.md)), o ligar el campo proyectado a un
array e indexar ese ([Proyectar un campo](project-field.md) — ojo con la
advertencia de BUG-1 ahí).

Mirá [Errores y limitaciones](../errors.md#errores-de-indexacion) para los
mensajes exactos.

## Relacionado

- [Slicear un sub-rango](slice-range.md) — `v[1:3].campo`
- [Proyectar un campo](project-field.md) — `v.campo`
