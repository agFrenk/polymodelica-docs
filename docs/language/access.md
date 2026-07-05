# Access and slicing

Three ways to read (and write) the contents of a polyvector: indexing a
single element, projecting a field across all elements, and slicing a
sub-range.

## Indexing: `v[i]`

`v[i]` denotes the i-th element (logical index, starting at 1) with its
**concrete** type, so fields that only exist on the subtype are accessible.
It works on both sides of an equation.

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

The index must be **resolvable at elaboration time**: an integer literal, a
`parameter`/`constant`, or an expression over them (`+`, `-`, `*`, integer
`/` all fold; `end` works too). The compiler resolves the index to a
sub-array and offset, and checks bounds, at compile time.

An index that is only known at runtime is rejected:

```modelica
Integer k;
equation
  k = 1;
  r = v[k].x;   // Error: index must be resolvable at elaboration
```

The error message itself names the two alternatives for dynamic access:
iterate with `for s in v loop` ([Iteration](iteration.md)), or project a
field first and index the resulting ordinary array (`v.x[i]`, below).

## Field slices: `v.field`

`v.field` projects one field across the whole polyvector, yielding an
ordinary array of length `size(v)`. This is the workhorse for aggregate
equations. Slices support:

- reductions: `sum`, `product`, `min`, `max`,
- element-wise arithmetic between slices (`v.x .* v.w`) and with scalars,
- element-wise math built-ins (`abs`, `sqrt`, `exp`, `sin`, ...),
- Boolean slices with `and` / `or` / `not`,
- `der()` on a slice: `der(v.x) = {1.0, 2.0, 3.0};`,
- shape queries: `size(v.x, 1)`, `ndims(v.x)`,
- nested component paths: `v.part.x` when `Base` contains a component `part`.

=== "PolyModelica"

    ```modelica
    --8<-- "AccessSlice.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real total;
    Real peak;
    Real weighted[4];
    Real scaled[4];
    equation
      total = sum(cat(1, base_v_a.x, base_v_b.x));
      peak = max(cat(1, base_v_a.x, base_v_b.x));
      weighted = cat(1, base_v_a.x, base_v_b.x) .* cat(1, base_v_a.w, base_v_b.w);
      scaled = 2.0 * cat(1, base_v_a.x, base_v_b.x);
    ```

A slice lowers to `cat(1, ...)` over the per-subtype arrays; each occurrence
of a slice in an expression gets its own `cat`.

!!! bug "Known issue: indexing into a field slice"

    `v.field[i]` — projecting first, then indexing with a dynamic `i` — is
    the intended escape hatch for runtime indices, but it currently
    mis-lowers (tracked as BUG-1 in the compiler's test suite). Until it is
    fixed, prefer `for s in v loop` or copy the slice into a declared array
    first: `Real xs[size(v)] = v.x;` then index `xs[i]`.

## Sub-polyvector slices: `v[range].field`

A contiguous or strictly increasing selection of elements can be sliced and
projected in one step, on either side of an equation:

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

A slice that spans several sub-arrays is split at the boundaries; when the
right-hand side is an array literal, the literal is split element-wise, and
otherwise the left side becomes a `cat(1, ...) = rhs` equation.

The subscript must be:

- a **literal range** `a:b` with `a <= b`, selecting at least two elements, or
- a **strictly increasing vector of integer literals** `{i1, ..., ik}`.

Everything else is rejected with a compile error: single-element ranges
(`v[3:3]` — use `v[3]`), empty ranges, stepped ranges (`v[1:2:6]`),
non-increasing vectors, parametric bounds (`v[k:k+2]`), and out-of-range
indices. See [Errors and limitations](../errors.md#slicing-errors).

## `connect` with slices

A sub-polyvector slice can be one side of a `connect`; the other side must be
a plain array reference (unsubscripted, or subscripted with a literal range):

```modelica
connect(c1, v[1:4].p);
// lowers to:
//   connect(c1[1:2], base_v_a[1:2].p);
//   connect(c1[3:4], base_v_b[1:2].p);
```

Connecting two sub-polyvector slices to each other, or to a
vector-subscripted reference like `c1[{1,2,3}]`, is not supported.
