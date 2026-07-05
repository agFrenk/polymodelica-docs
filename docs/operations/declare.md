# Declare a polyvector

Create one array that holds instances of *different* concrete subtypes of a
common `partial model`.

## Syntax

```modelica
polyvector Base[N] name = {Type1[n1], Type2[n2], ...};
polyvector Base name = {Type1[n1], Type2[n2], ...};   // N inferred
```

- `Base` — the **base type**: a `partial model` declaring what all elements
  share (variables, parameters, connectors).
- `TypeK` — a **concrete subtype**: a model that `extends Base`, directly or
  transitively.
- `TypeK[nK]` — a **sub-array**: `nK` consecutive elements of that type.
- `N` — the total size; must equal `n1 + n2 + ...`, or be omitted.

## Example

=== "PolyModelica"

    ```modelica
    --8<-- "DeclBasic.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    A base_v_a[3] annotation(
      __PolyModelica(polyvector = "v", baseType = "Base"));
    B base_v_b[2] annotation(
      __PolyModelica(polyvector = "v", baseType = "Base"));
    Real total;
    equation
      total = sum(cat(1, base_v_a.x, base_v_b.x));
    ```

Each sub-array lowers to one plain Modelica array tagged with a
`__PolyModelica` annotation (see [Lowering](../lowering.md)).

With the size omitted it is inferred from the sub-arrays (here 2 + 1 = 3):

```modelica
--8<-- "DeclInferred.mo"
```

## Element layout

Elements are contiguous, in declaration order. For
`polyvector Base[5] v = {A[3], B[2]}`:

| Logical index | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Concrete type | A | A | A | B | B |

The logical index is what you use everywhere — `v[4]` is the first `B`
element. The compiler translates logical indices into the right sub-array
and offset at elaboration time.

## Rules

- **One sub-array per subtype.** The same concrete type may not appear
  twice; group its elements into a single `Type[n]` entry.
- **Every subtype must derive from the base**, directly or through
  intermediate (possibly partial) models.
- **The declared size must match** the sum of sub-array sizes when given.
- **Empty sub-arrays are legal**: `{A[0], B[2]}` works, and loops over the
  empty run simply iterate zero times.
- A model may declare **several polyvectors**, including over the same base
  type.

Violations are compile-time errors with dedicated messages — see
[Errors and limitations](../errors.md#declaration-errors).

## See also

- [Query size and types](cardinality.md) — `size(v)`, `numTypes(v)`
- [Index an element](index-element.md) — `v[i]`
- [Iterate](iterate.md) — `for s in v loop`
