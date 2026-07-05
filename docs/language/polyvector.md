# Polyvectors

A polyvector is an array whose declared element type is a `partial model` and
whose elements are instances of concrete subtypes of it.

## Declaration

```modelica
polyvector Base[N] name = {Type1[n1], Type2[n2], ...};
```

- `Base` is the **base type**: a `partial model` that declares everything the
  elements have in common (variables, parameters, connectors).
- Each `TypeK` is a **concrete subtype**: a model that `extends Base`,
  directly or transitively.
- Each `TypeK[nK]` is a **sub-array**: `nK` consecutive elements of that type.
- `N` is the total size and must equal `n1 + n2 + ...`.

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

Each sub-array lowers to one plain Modelica array, tagged with a
`__PolyModelica` annotation that records which polyvector it came from
(see [Lowering](../lowering.md)).

## Element layout

Elements are laid out contiguously, in declaration order. For
`polyvector Base[5] v = {A[3], B[2]}`:

| Logical index | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Concrete type | A | A | A | B | B |

The logical index is what you use everywhere — `v[4]` is the first `B`
element. The compiler translates logical indices into the right sub-array
and offset at elaboration time.

## Inferred total size

The total size may be omitted; it is then the sum of the sub-array sizes:

```modelica
--8<-- "DeclInferred.mo"
```

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

## Cardinality built-ins

Three built-ins query a polyvector's shape, plus one new one. All of them
fold to integer constants during elaboration, so they can be used anywhere a
constant is expected — including array dimensions:

| Built-in | Meaning | Example result |
| --- | --- | --- |
| `size(v)` / `size(v, 1)` | total number of elements | `5` |
| `ndims(v)` | number of dimensions (always) | `1` |
| `numTypes(v)` | number of sub-arrays (distinct subtypes) | `3` |

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

`numTypes` only exists for polyvectors. `size` and `ndims` applied to
ordinary arrays are left untouched — the rewrite only fires when the argument
is a polyvector.
