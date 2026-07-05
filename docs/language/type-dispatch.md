# Type dispatch

Inside a `for s in v loop`, the concrete type of `s` is known per sub-array.
PolyModelica exploits that with three type predicates and a `match`
construct. All of them are resolved **statically**: the compiler picks the
branch that is true for each sub-array and emits only that branch's code —
no runtime type tags, no dead conditionals.

## Predicates: `is`, `isType`, `isSubtype`

| Predicate | True when |
| --- | --- |
| `s is T` | the concrete type of `s` is exactly `T` |
| `isType(s, T)` | same as `s is T`, function form |
| `isSubtype(s, T)` | the concrete type of `s` extends `T` (or is `T`), directly or transitively |

They can appear in `if`/`elseif` conditions, combined with `and`/`or`/`not`,
and even as Boolean values on the right-hand side of an equation (where they
fold to `true`/`false` per sub-array). `isSubtype` is what makes intermediate
`partial` levels of the hierarchy useful as dispatch targets.

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

Note what happened: the `if isType(s, A) / elseif isSubtype(s, Mid) / else`
chain vanished. Each sub-array's loop contains only the branch that applies
to it.

### Type narrowing

Inside a branch guarded by a predicate, the iterator is **narrowed** to the
tested type, so fields that only exist on the subtype are accessible:

```modelica
--8<-- "DispatchIs.mo"
```

`s.a` is legal in the `then` branch because there `s` is known to be an `A`.

!!! info "`is` is a soft keyword"

    `is` only acts as an operator in condition position. `Real is;` is still
    a perfectly legal declaration, so existing models that use `is` as an
    identifier keep working.

## `match` / `case` / `otherwise`

`match` dispatches on the concrete type of an element. It comes in two
forms: as an **expression** and as an **equation** whose cases contain full
equations.

=== "PolyModelica"

    ```modelica
    --8<-- "DispatchMatch.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real rate[6];
    Real w[6];
    equation
      for s in 1:2 loop
        rate[s] = 1.0;
        w[s] = 0.10 * base_v_a[s].x;
      end for;
      for s in 1:2 loop
        rate[2 + s] = 1.2;
        w[2 + s] = 0.10 * base_v_b[s].x;
      end for;
      for s in 1:2 loop
        rate[4 + s] = 0.8;
        w[4 + s] = base_v_c[s].c;
      end for;
    ```

Case selectors:

| Selector | Matches |
| --- | --- |
| `case T:` | elements of concrete type `T` |
| `case T1 \| T2:` | OR-pattern: either type, one shared body |
| `case isSubtype T:` | any type extending `T` (note: no parentheses) |
| `otherwise:` | everything not matched above |

Semantics:

- **First match wins.** With overlapping cases (`case C:` before
  `case isSubtype Mid:` where `C extends Mid`), an element takes the first
  case that matches it.
- **Exhaustiveness is checked.** Every concrete type present in the
  polyvector must be covered by some case or by `otherwise:`; a missing type
  is a compile error naming the uncovered type.
- Inside a case body the element is narrowed to the case's type, exactly as
  with predicates.
