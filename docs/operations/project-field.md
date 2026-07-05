# Project a field

Take one field across **all** elements of a polyvector at once, as an
ordinary array of length `size(v)`. This is the workhorse for aggregate
equations like `sum(agents.wealth)`.

## Syntax

```modelica
v.field            // ordinary array, length size(v)
v.part.field       // nested component paths work too
```

## Example

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

A projected field lowers to `cat(1, ...)` over the per-subtype arrays; each
occurrence in an expression gets its own `cat`.

## What you can do with a projected field

- reductions: `sum`, `product`, `min`, `max`,
- element-wise arithmetic between slices (`v.x .* v.w`) and with scalars,
- element-wise math built-ins (`abs`, `sqrt`, `exp`, `sin`, ...),
- Boolean fields with `and` / `or` / `not`,
- `der()` on the projection: `der(v.x) = {1.0, 2.0, 3.0};`,
- shape queries: `size(v.x, 1)`, `ndims(v.x)`,
- bindings (declaration equations): `Real xs[size(v)] = v.x;`.

## Rules

!!! bug "Known issue: indexing into a projection"

    `v.field[i]` — projecting first, then indexing with a dynamic `i` — is
    the intended escape hatch for runtime indices, but it currently
    mis-lowers (tracked as BUG-1 in the compiler's test suite). Until it is
    fixed, prefer `for s in v loop` ([Iterate](iterate.md)) or copy the
    projection into a declared array first: `Real xs[size(v)] = v.x;` then
    index `xs[i]`.

## See also

- [Slice a sub-range](slice-range.md) — project only part of the vector
- [Build arrays (comprehensions)](comprehend.md) — per-element expressions
