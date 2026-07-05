# Despachar con match

Darle a cada elemento un comportamiento por tipo en una sola construcción.
`match` despacha sobre el tipo concreto de un elemento y viene en dos
formas: como **expresión** y como **ecuación** cuyos cases contienen
ecuaciones completas. Igual que los [predicados de tipo](test-types.md), se
compila y desaparece por completo.

## Sintaxis

```modelica
// forma de expresión
x = match s
      case T1:    expr1;
      otherwise:  expr2;
    end match;

// forma de ecuación
match s
  case T1:            <ecuaciones>;
  case T2 | T3:       <ecuaciones>;
  case isSubtype T4:  <ecuaciones>;
  otherwise:          <ecuaciones>;
end match;
```

| Selector | Matchea |
| --- | --- |
| `case T:` | elementos de tipo concreto `T` |
| `case T1 \| T2:` | patrón OR: cualquiera de los dos tipos, un cuerpo compartido |
| `case isSubtype T:` | cualquier tipo que extienda `T` (ojo: sin paréntesis) |
| `otherwise:` | todo lo no matcheado arriba |

## Ejemplo

=== "PolyModelica"

    ```modelica
    --8<-- "DispatchMatch.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real rate[6];
    Real w[6];
    equation
      for s in 1:2 loop
        rate[s] = 1.0;
        w[s] = 0.10 * base_v_a[s].x;
      end for;
      for s in 1:2 loop
        rate[2 + s] = 1.2;
        w[2 + s] = 0.10 * base_v_b[s].x;
      end for;
      for s in 1:2 loop
        rate[4 + s] = 0.8;
        w[4 + s] = base_v_c[s].c;
      end for;
    ```

## Estrechamiento de tipo en los cuerpos de los cases

Dentro del cuerpo de un case el elemento queda **estrechado** al tipo del
case, exactamente igual que en una rama `if s is A`
([Consultar el tipo de un elemento](test-types.md#estrechamiento-de-tipo)) —
así que los campos que solo existen en un subtipo son accesibles bajo su
case:

=== "PolyModelica"

    ```modelica
    --8<-- "MatchNarrow.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real w[4];
    equation
      for s in 1:2 loop
        w[s] = base_v_a[s].a;
      end for;
      for s in 1:2 loop
        w[2 + s] = base_v_b[s].b;
      end for;
    ```

`s.a` es legal bajo `case A:` y `s.b` bajo `case B:`, aunque ninguno de los
dos campos exista en `Base`. Un `case isSubtype Mid:` estrecha a `Mid`, así
que los campos declarados en `Mid` son accesibles.

!!! warning "Los OR-patterns estrechan a lo que los tipos comparten"

    Bajo `case A | B:` el cuerpo se emite para **ambos** tipos, así que solo
    puede usar campos comunes a todos ellos. Esto no compila:

    ```modelica
    match s
      case A | B: w[s] = s.a;   // Error: Variable base_v_b[s].a
    end match;                  //        not found in scope
    ```

    Partí el case (`case A:` / `case B:`) cuando los cuerpos necesitan
    campos específicos del subtipo. Es una
    [limitación conocida](../errors.md#los-or-patterns-no-estrechan-por-tipo-matcheado)
    marcada para arreglar en una revisión futura.

## Reglas

- **Gana el primer match.** Con cases superpuestos (`case C:` antes de
  `case isSubtype Mid:` donde `C extends Mid`), un elemento toma el primer
  case que lo matchea.
- **La exhaustividad se chequea.** Todo tipo concreto presente en el
  polyvector debe estar cubierto por algún case o por `otherwise:`; un tipo
  faltante es un error de compilación que nombra el tipo sin cubrir
  ([Errores y limitaciones](../errors.md#errores-de-despacho-e-iteracion)).

## Relacionado

- [Consultar el tipo de un elemento](test-types.md) — `is`, `isType`,
  `isSubtype`
- [Iterar](iterate.md) — el loop en el que vive el `match`
