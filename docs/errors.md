# Errors and limitations

PolyModelica enforces its restrictions with dedicated compile-time errors,
all prefixed with `PolyModelica:`. This page lists every one of them, what
triggers it, and how to fix it — followed by the known limitations of the
current implementation.

## Declaration errors

**Duplicate subtype**

```modelica
polyvector Base[5] v = {A[3], A[2]};
```
> PolyModelica: type A appears in more than one sub-array of polyvector v;
> group same-type elements into a single Type[N] declaration.

Fix: `{A[5]}`.

**Size mismatch**

```modelica
polyvector Base[4] v = {A[3], B[2]};
```
> PolyModelica: polyvector v declares total size 4 but its sub-arrays sum
> to 5.

Fix: correct the total, or omit it and let it be inferred
(`polyvector Base v = ...`).

**Subtype does not derive from the base**

```modelica
polyvector Base[2] v = {A[1], Other[1]};   // Other does not extend Base
```
> PolyModelica: type Other of polyvector v is not derived from its base type
> Base. A sub-array type must extend Base, directly or transitively.

Unlike the others, this one is reported when the model is *checked* (it comes
from the front end's nominal subtype check), not at load time.

## Indexing errors

**Dynamic index**

```modelica
Integer k;
equation
  k = 1;
  r = v[k].x;
```
> PolyModelica: the index of polyvector v must be resolvable at elaboration
> (an integer literal, a parameter/constant, or an expression over them).
> Use 'for s in v loop ... end for;' to iterate over all elements, or project
> a field first ('v.field[i]') to index dynamically.

**Out of range**

```modelica
r = v[5].x;   // v has 2 elements
```
> PolyModelica: index 5 is out of range for polyvector v, which has 2
> element(s).

## Slicing errors

The subscript of a sub-polyvector slice `v[...].field` must be a literal
range `a:b` (`a <= b`, at least two elements) or a strictly increasing vector
of integer literals.

| Trigger | Error |
| --- | --- |
| `v[3:3].w` | *the sub-polyvector subscript of v selects a single element. Use v[i] directly…* |
| `v[3:2].w` | *the sub-polyvector subscript of v selects no elements; an empty sub-polyvector is not allowed.* |
| `v[1:2:6].w`, `v[{3,1,5}].w`, `v[k:k+2].w` | *the sub-polyvector subscript of v must be a literal range a:b (a <= b) or a strictly increasing vector of integer literals {i1, ..., ik}. Stepped ranges, parametric bounds and non-literal entries are not allowed.* |
| `v[2:8].w` (size 6) | *index 7 is out of range for polyvector v, which has 6 element(s).* |

**Connect restrictions**

```modelica
connect(v1[1:4].p, v2[1:4].p);        // two poly sides
connect(v[1:4].p, c1[{1,2,3,4}]);     // vector-subscripted plain side
```
> PolyModelica: a connect with a sub-polyvector slice must have exactly one
> sub-polyvector side, connected to a plain array reference (an unsubscripted
> name or a name with a literal range subscript a:b). Connecting two
> sub-polyvectors, or to a vector-subscripted reference, is not supported.

## Dispatch and iteration errors

**Non-exhaustive match**

```modelica
match s
  case A: w[s] = s.x;   // polyvector also contains B
end match;
```
> PolyModelica: match is not exhaustive; the concrete type B is not covered
> by any case. Add a case for it or an 'otherwise:' branch.

**Too many polyvector iterators**

```modelica
for a in v, b in v, c in v, d in v, e in v, f in v loop
```
> PolyModelica: a for-chain may iterate over at most 5 polyvectors (the
> cartesian product blows up); found 6 nested polyvector iterators.

Five is fine; six is not.

**Value-based comprehension filter**

```modelica
bad = {s.x for s in v if s.x > 10};
```
> PolyModelica: a comprehension filter must be a type predicate (s is T,
> isType(s, T), isSubtype(s, T), combined with and/or/not) that resolves per
> sub-array at elaboration; value conditions are not allowed.

## Known limitations

### OMEdit and graphical editing

OMEdit regenerates a class's source text from the compiler's symbol table —
which holds the **lowered** program — whenever it needs to rewrite the file.
In practice:

- **Safe:** editing your model in the *text view* and saving.
- **Not safe:** saving after a *graphical* edit (drawing in the Icon/Diagram
  views, changing values through dialogs). This rewrites the `.mo` file with
  the lowered code, and your `polyvector` declarations are replaced by the
  generated arrays.

Keep PolyModelica sources under version control, and treat graphical edits
as read-only exploration. (Verified empirically on the current fork.)

### Indexing into a field slice (BUG-1)

`v.field[i]` — the documented escape hatch for dynamic indexing — currently
produces an incorrect lowering. The compiler's own test suite tracks this as
a known-failing test (BUG-1). Workarounds: iterate with `for s in v loop`,
or bind the slice to an array first (`Real xs[size(v)] = v.x;`) and index
that.

### Scope of the constructs

Iteration, dispatch and comprehension forms are specified (and tested) as
**equation-section** constructs. Algorithm-section usage is not part of the
current test surface.
