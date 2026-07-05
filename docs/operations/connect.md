# Connect slices

Wire the connectors of a sub-range of elements to a plain connector array
with one `connect` equation.

## Syntax

```modelica
connect(c, v[a:b].port);          // plain side unsubscripted
connect(v[{1,3,5}].port, c[1:3]); // or with a literal range
```

Either argument order works; the polyvector slice may come first or second.

## Example

```modelica
connect(c1, v[1:4].p);
// lowers to:
//   connect(c1[1:2], base_v_a[1:2].p);
//   connect(c1[3:4], base_v_b[1:2].p);
```

The slice is split at sub-array boundaries and the plain side is split into
matching sub-ranges.

## Rules

- Exactly **one** side may be a sub-polyvector slice.
- The other side must be a **plain array reference**: an unsubscripted name,
  or a name subscripted with a literal range `a:b`.
- Not allowed: connecting two sub-polyvector slices to each other, or a
  plain side with a vector subscript like `c1[{1,2,3,4}]`.
- The slice subscript follows the same rules as any sub-range slice
  ([Slice a sub-range](slice-range.md)).

The rejected forms produce a dedicated error — see
[Errors and limitations](../errors.md#slicing-errors).
