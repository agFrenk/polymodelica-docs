# Slice a sub-range

Select a subset of elements and project a field over it, in one step, on
either side of an equation.

## Syntax

```modelica
v[a:b].field           // literal range, a <= b, at least two elements
v[{i1, i2, ...}].field // strictly increasing vector of integer literals
```

## Example

=== "PolyModelica"

    ```modelica
    --8<-- "AccessSubslice.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real ys[3];
    equation
      base_v_a[1:2].y = {1.5, 1.0};
      base_v_b[1:1].y = {0.9};
      ys = cat(1, base_v_a[1:1].x, base_v_b[1:1].x, base_v_c[1:1].x);
      base_v_b[2:2].y = {0.5};
      base_v_c[1:2].y = {0.4, 0.3};
    ```

A slice that spans several sub-arrays is split at the boundaries. When the
right-hand side is an array literal, the literal is split element-wise;
otherwise the left side becomes a single `cat(1, ...) = rhs` equation.

## Rules

The subscript must be:

- a **literal range** `a:b` with `a <= b`, selecting at least two elements, or
- a **strictly increasing vector of integer literals** `{i1, ..., ik}`.

Everything else is a compile error:

| Rejected | Why |
| --- | --- |
| `v[3:3].w` | single element — use `v[3].w` |
| `v[3:2].w` | empty selection |
| `v[1:2:6].w` | stepped range |
| `v[{3,1,5}].w` | not strictly increasing |
| `v[k:k+2].w` | parametric bounds |
| `v[2:8].w` on size 6 | out of range |

See [Errors and limitations](../errors.md#slicing-errors) for the exact
messages.

## See also

- [Index an element](index-element.md) — single element, `v[i]`
- [Project a field](project-field.md) — the whole vector, `v.field`
- [Connect slices](connect.md) — slices as `connect` arguments
