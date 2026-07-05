# Test an element's type

Ask, inside a `for s in v loop`, what an element actually is, and act on the
answer. The tests are resolved **statically**: the compiler knows the
concrete type per sub-array, evaluates each predicate to a constant, and
emits only the surviving branch — no runtime type tags, no dead
conditionals.

## Syntax

| Predicate | True when |
| --- | --- |
| `s is T` | the concrete type of `s` is exactly `T` |
| `isType(s, T)` | same as `s is T`, function form |
| `isSubtype(s, T)` | the concrete type of `s` extends `T` (or is `T`), directly or transitively |

Usable in `if`/`elseif` conditions, combined with `and`/`or`/`not`, and as
Boolean values on the right-hand side of an equation (where they fold to
`true`/`false` per sub-array). `isSubtype` is what makes intermediate
`partial` levels of the hierarchy useful as dispatch targets.

## Example

=== "PolyModelica"

    ```modelica
    --8<-- "DispatchPredicates.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real w[6];
    Boolean q[6];
    equation
      for s in 1:2 loop
        w[s] = base_v_a[s].a;
        q[s] = false;
      end for;
      for s in 1:2 loop
        w[2 + s] = 0;
        q[2 + s] = false;
      end for;
      for s in 1:2 loop
        w[4 + s] = base_v_c[s].c;
        q[4 + s] = true;
      end for;
    ```

The `if isType(s, A) / elseif isSubtype(s, Mid) / else` chain vanished: each
sub-array's loop contains only the branch that applies to it.

## Type narrowing

Inside a branch guarded by a predicate, the iterator is **narrowed** to the
tested type, so fields that only exist on the subtype are accessible:

```modelica
--8<-- "DispatchIs.mo"
```

`s.a` is legal in the `then` branch because there `s` is known to be an `A`.

## Rules

!!! info "`is` is a soft keyword"

    `is` only acts as an operator in condition position. `Real is;` is still
    a perfectly legal declaration, so existing models that use `is` as an
    identifier keep working.

- `isType` is exact: a `C` that extends `Mid` satisfies `isSubtype(s, Mid)`
  but not `isType(s, Mid)`.
- The same predicates are the only thing accepted as
  [comprehension filters](comprehend.md#filter-by-type).

## See also

- [Dispatch with match](match.md) — the multi-way version of this operation
- [Iterate](iterate.md) — the loop these tests live in
