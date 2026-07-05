# Query size and types

Ask a polyvector how many elements and how many distinct subtypes it has.
All of these fold to integer constants during elaboration, so they can be
used anywhere a constant is expected — including array dimensions.

## Syntax

| Built-in | Meaning | Example result |
| --- | --- | --- |
| `size(v)` / `size(v, 1)` | total number of elements | `5` |
| `ndims(v)` | number of dimensions (always) | `1` |
| `numTypes(v)` | number of sub-arrays (distinct subtypes) | `3` |

## Example

=== "PolyModelica"

    ```modelica
    --8<-- "DeclCardinality.mo"
    ```

=== "Lowered Modelica"

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

Note `Real xs[size(v)]` and `Real weight[numTypes(v)]`: the built-ins are
valid dimension expressions because they are constants by the time the rest
of the compiler sees them.

## Rules

- `numTypes` only exists for polyvectors.
- `size` and `ndims` applied to **ordinary** arrays are left untouched — the
  rewrite only fires when the argument is a polyvector.
- Shape queries also work on projected fields: `size(v.x, 1)`, `ndims(v.x)`
  (see [Project a field](project-field.md)).

## See also

- [Declare a polyvector](declare.md)
- [Iterate](iterate.md) — `for i in 1:size(v) loop`
