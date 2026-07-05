# Build arrays (comprehensions)

Build an array — or feed a reduction — from a polyvector, element by
element, optionally keeping only elements of certain types.

## Syntax

```modelica
{expr(s) for s in v}                    // array, one entry per element
sum(expr(s) for s in v)                 // reduction, also min/max/product
{expr(s) for s in v if <type test>}     // filtered
```

## Example

=== "PolyModelica"

    ```modelica
    --8<-- "CompBasic.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real xw[4];
    Real total;
    equation
      xw = {base_v_a[1].x*base_v_a[1].w, base_v_a[2].x*base_v_a[2].w,
            base_v_b[1].x*base_v_b[1].w, base_v_b[2].x*base_v_b[2].w};
      total = sum({base_v_a[1].x, base_v_a[2].x, base_v_b[1].x, base_v_b[2].x});
    ```

Comprehensions are **fully unrolled** at elaboration into explicit array
literals — one term per element, in logical order. They work in equations
and in bindings (declaration equations), e.g.
`parameter Real sq[4] = {s.w * s.w for s in v};`.

## Filter by type

The filter is a [type predicate](test-types.md) — `s is T`, `isType(s, T)`,
`isSubtype(s, T)`, combined with `and` / `or` / `not`:

=== "PolyModelica"

    ```modelica
    --8<-- "CompFilter.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real as[2];
    Real cs[2];
    Real xs[4];
    Real totalA;
    equation
      as = {base_v_a[1].a, base_v_a[2].a};
      cs = {base_v_c[1].c, base_v_c[2].c};
      xs = {base_v_a[1].x, base_v_a[2].x, base_v_b[1].x, base_v_b[2].x};
      totalA = sum({base_v_a[1].x, base_v_a[2].x});
    ```

- **The result length is the number of matching elements**, not the size of
  the polyvector — `as` has 2 entries, not 6. Since filters resolve at
  compile time, the length is still a compile-time constant.
- **The filter narrows the element type in the body**: `s.a` is legal in the
  first comprehension because only `A` elements survive the filter, and
  `s.c` in the second because `isSubtype(s, Mid)` selects the whole subtree
  under `Mid`.

## Rules

The filter must be decidable per sub-array at elaboration time. A condition
on runtime **values** is rejected:

```modelica
bad = {s.x for s in v if s.x > 10};
// Error: a comprehension filter must be a type predicate
// (s is T, isType(s, T), isSubtype(s, T), combined with and/or/not)
```

For value-dependent selection, compute over the full projection with
standard Modelica means (e.g. `noEvent(if ... then ... else ...)`
element-wise on `v.x`) or handle it inside a `for` loop.

## See also

- [Project a field](project-field.md) — when the expression is just one field
- [Iterate](iterate.md) — equations per element instead of an array
