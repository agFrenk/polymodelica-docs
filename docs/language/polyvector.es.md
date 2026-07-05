# Polyvectors

Un polyvector es un array cuyo tipo de elemento declarado es un
`partial model` y cuyos elementos son instancias de subtipos concretos de él.

## Declaración

```modelica
polyvector Base[N] nombre = {Tipo1[n1], Tipo2[n2], ...};
```

- `Base` es el **tipo base**: un `partial model` que declara todo lo que los
  elementos tienen en común (variables, parámetros, conectores).
- Cada `TipoK` es un **subtipo concreto**: un modelo que hace
  `extends Base`, directa o transitivamente.
- Cada `TipoK[nK]` es un **sub-array**: `nK` elementos consecutivos de ese
  tipo.
- `N` es el tamaño total y debe ser igual a `n1 + n2 + ...`.

=== "PolyModelica"

    ```modelica
    --8<-- "DeclBasic.mo"
    ```

=== "Modelica loweado"

    ```modelica
    A base_v_a[3] annotation(
      __PolyModelica(polyvector = "v", baseType = "Base"));
    B base_v_b[2] annotation(
      __PolyModelica(polyvector = "v", baseType = "Base"));
    Real total;
    equation
      total = sum(cat(1, base_v_a.x, base_v_b.x));
    ```

Cada sub-array se lowea a un array Modelica común, etiquetado con una
annotation `__PolyModelica` que registra de qué polyvector salió
(mirá [Lowering](../lowering.md)).

## Disposición de los elementos

Los elementos se disponen en forma contigua, en orden de declaración. Para
`polyvector Base[5] v = {A[3], B[2]}`:

| Índice lógico | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Tipo concreto | A | A | A | B | B |

El índice lógico es el que usás en todos lados — `v[4]` es el primer
elemento `B`. El compilador traduce índices lógicos al sub-array y offset
correctos en tiempo de elaboración.

## Tamaño total inferido

El tamaño total se puede omitir; en ese caso es la suma de los tamaños de
los sub-arrays:

```modelica
--8<-- "DeclInferred.mo"
```

## Reglas

- **Un sub-array por subtipo.** El mismo tipo concreto no puede aparecer dos
  veces; agrupá sus elementos en una única entrada `Tipo[n]`.
- **Todo subtipo debe derivar del base**, directamente o a través de modelos
  intermedios (posiblemente parciales).
- **El tamaño declarado debe coincidir** con la suma de los sub-arrays
  cuando se indica.
- **Los sub-arrays vacíos son válidos**: `{A[0], B[2]}` funciona, y los
  loops sobre el tramo vacío simplemente iteran cero veces.
- Un modelo puede declarar **varios polyvectors**, incluso sobre el mismo
  tipo base.

Las violaciones son errores de compilación con mensajes dedicados — mirá
[Errores y limitaciones](../errors.md#errores-de-declaracion).

## Built-ins de cardinalidad

Tres built-ins consultan la forma de un polyvector, más uno nuevo. Todos se
pliegan a constantes enteras durante la elaboración, así que se pueden usar
donde se espera una constante — incluidas las dimensiones de arrays:

| Built-in | Significado | Resultado de ejemplo |
| --- | --- | --- |
| `size(v)` / `size(v, 1)` | cantidad total de elementos | `5` |
| `ndims(v)` | cantidad de dimensiones (siempre) | `1` |
| `numTypes(v)` | cantidad de sub-arrays (subtipos distintos) | `3` |

=== "PolyModelica"

    ```modelica
    --8<-- "DeclCardinality.mo"
    ```

=== "Modelica loweado"

    ```modelica
    constant Integer total = 5;
    constant Integer dims = 1;
    constant Integer types = 3;
    parameter Real weight[3] = {0.5, 0.3, 0.2};
    Real xs[5];
    equation
      for k in 1:2 loop
        xs[k] = base_v_a[k].x;
      end for;
      for k in 3:4 loop
        xs[k] = base_v_b[k - 2].x;
      end for;
      for k in 5:5 loop
        xs[k] = base_v_c[k - 4].x;
      end for;
    ```

`numTypes` solo existe para polyvectors. `size` y `ndims` aplicados a arrays
comunes quedan intactos — la reescritura solo se dispara cuando el argumento
es un polyvector.
