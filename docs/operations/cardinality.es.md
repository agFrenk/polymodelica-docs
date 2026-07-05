# Consultar tamaño y tipos

Preguntarle a un polyvector cuántos elementos y cuántos subtipos distintos
tiene. Todos estos built-ins se pliegan a constantes enteras durante la
elaboración, así que se pueden usar donde se espera una constante —
incluidas las dimensiones de arrays.

## Sintaxis

| Built-in | Significado | Resultado de ejemplo |
| --- | --- | --- |
| `size(v)` / `size(v, 1)` | cantidad total de elementos | `5` |
| `ndims(v)` | cantidad de dimensiones (siempre) | `1` |
| `numTypes(v)` | cantidad de sub-arrays (subtipos distintos) | `3` |

## Ejemplo

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

Fijate en `Real xs[size(v)]` y `Real weight[numTypes(v)]`: los built-ins son
expresiones de dimensión válidas porque ya son constantes cuando el resto
del compilador los ve.

## Reglas

- `numTypes` solo existe para polyvectors.
- `size` y `ndims` aplicados a arrays **comunes** quedan intactos — la
  reescritura solo se dispara cuando el argumento es un polyvector.
- Las consultas de forma también funcionan sobre campos proyectados:
  `size(v.x, 1)`, `ndims(v.x)` (mirá
  [Proyectar un campo](project-field.md)).

## Relacionado

- [Declarar un polyvector](declare.md)
- [Iterar](iterate.md) — `for i in 1:size(v) loop`
