# Dispatch with match

Give each element a per-type behavior in one construct. `match` dispatches
on the concrete type of an element and comes in two forms: as an
**expression**, and as an **equation** whose cases contain full equations.
Like the [type predicates](test-types.md), it compiles away entirely.

## Syntax

```modelica
// expression form
x = match s
      case T1:    expr1;
      otherwise:  expr2;
    end match;

// equation form
match s
  case T1:            <equations>;
  case T2 | T3:       <equations>;
  case isSubtype T4:  <equations>;
  otherwise:          <equations>;
end match;
```

| Selector | Matches |
| --- | --- |
| `case T:` | elements of concrete type `T` |
| `case T1 \| T2:` | OR-pattern: either type, one shared body |
| `case isSubtype T:` | any type extending `T` (note: no parentheses) |
| `otherwise:` | everything not matched above |

## Example

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

## Type narrowing in case bodies

Inside a case body the element is **narrowed** to the case's type, exactly
as with an `if s is A` branch ([Test an element's type](test-types.md#type-narrowing)) —
so fields that only exist on one subtype are accessible under its case:

=== "PolyModelica"

    ```modelica
    --8<-- "MatchNarrow.mo"
    ```

=== "Lowered Modelica"

    ```modelica
    Real w[4];
    equation
      for s in 1:2 loop
        w[s] = base_v_a[s].a;
      end for;
      for s in 1:2 loop
        w[2 + s] = base_v_b[s].b;
      end for;
    ```

`s.a` is legal under `case A:` and `s.b` under `case B:`, even though
neither field exists on `Base`. A `case isSubtype Mid:` narrows to `Mid`,
so fields declared in `Mid` are accessible.

!!! warning "OR-patterns narrow to what the types share"

    Under `case A | B:` the body is emitted for **both** types, so it may
    only use fields common to all of them. This fails to compile:

    ```modelica
    match s
      case A | B: w[s] = s.a;   // Error: Variable base_v_b[s].a
    end match;                  //        not found in scope
    ```

    Split the case (`case A:` / `case B:`) when the bodies need
    subtype-specific fields.

## Rules

- **First match wins.** With overlapping cases (`case C:` before
  `case isSubtype Mid:` where `C extends Mid`), an element takes the first
  case that matches it.
- **Exhaustiveness is checked.** Every concrete type present in the
  polyvector must be covered by some case or by `otherwise:`; a missing type
  is a compile error naming the uncovered type
  ([Errors and limitations](../errors.md#dispatch-and-iteration-errors)).

## See also

- [Test an element's type](test-types.md) — `is`, `isType`, `isSubtype`
- [Iterate](iterate.md) — the loop `match` lives in
