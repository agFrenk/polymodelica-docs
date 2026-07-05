# Iterate

Loop over a polyvector's elements. Two forms: iterate the **elements**
directly (`for s in v` — the iterator is an instance, subtype dispatch works
on it), or iterate a **numeric range** and index (`for i in 1:size(v)` with
`v[i]`).

## Iterate elements: `for s in v`

The iterator is bound to each element in turn, with its concrete type known
per sub-array — this is what enables
[type tests](test-types.md) and [match](match.md) in the body. Used inside
array subscripts, `s` acts as the element's logical index.

=== "PolyModelica"

    ```modelica
    --8<-- "IterPolyFor.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real w[5];
    equation
      for s in 1:3 loop
        w[s] = base_v_a[s].x - base_v_a[s].z;
      end for;
      for s in 1:2 loop
        w[3 + s] = base_v_b[s].x - base_v_b[s].z;
      end for;
    ```

The loop splits into one loop per sub-array, each over the *local* range
`1:n`; subscripts of other arrays that use the iterator get the sub-array's
global offset added (`w[3 + s]`).

## Iterate by index: `for i in 1:size(v)`

An ordinary integer loop whose body indexes the polyvector. The range is
split at sub-array boundaries; the ranges keep their **global** bounds and
the polyvector subscript is re-based instead:

=== "PolyModelica"

    ```modelica
    --8<-- "IterNumeric.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real w[5];
    equation
      for i in 1:3 loop
        w[i] = base_v_a[i].x;
      end for;
      for i in 4:5 loop
        w[i] = base_v_b[i - 3].x;
      end for;
    ```

The range does not have to cover the whole vector or align with sub-array
boundaries — `for i in 2:4 loop` over `{A[3], B[2]}` splits into `2:3` and
`4:4`.

## Nest loops

Polyvector iterators compose: comma-separated iterator chains and physically
nested loops are equivalent and both produce the full cartesian expansion,
one loop nest per combination of sub-arrays. Iterators may range over the
same polyvector or different ones, and numeric and polyvector iterators mix
freely at any nesting level.

=== "PolyModelica"

    ```modelica
    --8<-- "IterNested.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real y[2, 2];
    equation
      for s in 1:1 loop
        for t in 1:1 loop
          y[s, t] = base_v_a[s].x * base_v_a[t].x;
        end for;
        for t in 1:1 loop
          y[s, 1 + t] = base_v_a[s].x * base_v_b[t].x;
        end for;
      end for;
      for s in 1:1 loop
        for t in 1:1 loop
          y[1 + s, t] = base_v_b[s].x * base_v_a[t].x;
        end for;
        for t in 1:1 loop
          y[1 + s, 1 + t] = base_v_b[s].x * base_v_b[t].x;
        end for;
      end for;
    ```

## Rules

!!! warning "At most 5 polyvector iterators per for-chain"

    The lowering multiplies out sub-array combinations, so the generated code
    grows with the cartesian product. A single for-chain may iterate over at
    most **5** polyvectors; a sixth is a compile error
    ([Errors and limitations](../errors.md#dispatch-and-iteration-errors)).

- All the forms above are equation-section constructs (that is where the
  dialect's test suite exercises them).
- An empty sub-array (`A[0]`) lowers to a `1:0` loop, which simply iterates
  zero times.

## See also

- [Test an element's type](test-types.md) and [Dispatch with match](match.md)
  — per-type behavior inside the loop body
- [Build arrays (comprehensions)](comprehend.md) — build an array instead of
  writing equations per element
