# Index an element

Access one element by its logical position, with its **concrete** type — so
fields that only exist on the subtype are accessible. Works on both sides of
an equation.

## Syntax

```modelica
v[i].field         // i: literal, parameter/constant, or expression over them
v[end].field       // last element
```

## Example

=== "PolyModelica"

    ```modelica
    --8<-- "AccessIndex.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    parameter Integer k = 2;
    Real r1, r2, r3, r4;
    equation
      r1 = base_v_a[2].x;
      r2 = base_v_b[1].x;
      r3 = base_v_b[2].x;
      r4 = base_v_a[1].x - base_v_b[1].z;
    ```

The compiler resolves each logical index to a sub-array and local offset at
elaboration time — `v[4]` on `{A[3], B[2]}` becomes `base_v_b[1]`.

## Rules

- The index must be **resolvable at elaboration**: an integer literal, a
  `parameter`/`constant`, or an expression over them. `+`, `-`, `*` and
  integer `/` all fold; `end` works too.
- Bounds are checked at compile time; an out-of-range literal is an error.
- An index only known at runtime is rejected:

```modelica
Integer k;
equation
  k = 1;
  r = v[k].x;   // Error: index must be resolvable at elaboration
```

The error message names the alternatives for dynamic access: iterate with
`for s in v loop` ([Iterate](iterate.md)), or bind the projected field to an
array and index that ([Project a field](project-field.md) — note the BUG-1
caveat there).

See [Errors and limitations](../errors.md#indexing-errors) for the exact
messages.

## See also

- [Slice a sub-range](slice-range.md) — `v[1:3].field`
- [Project a field](project-field.md) — `v.field`
