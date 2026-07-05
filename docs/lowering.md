# Lowering

Every PolyModelica construct is rewritten into standard Modelica **at parse
time**, before any other compiler stage runs. This page documents the
contract: what each construct becomes.

## Where it happens

With `--grammar=PolyModelica`, the parser hands the freshly parsed program to
an elaboration pass (`PolyModelicaElaboration.elaborate()`) that returns
100% vanilla Modelica. The compiler's symbol table only ever holds the
lowered program, which has two practical consequences:

- `list(Model)` and `listFile(Model)` — and OMEdit's **View Lowered
  Modelica** — show the lowered code, making the whole dialect inspectable.
- Everything downstream of the parser (flattening, solvers, FMI export,
  plotting) is stock OpenModelica and needs no changes.

The only PolyModelica-aware check outside the parser is a nominal subtype
check in the new front end, which rejects polyvector sub-arrays whose type
does not derive from the base type.

## Declarations

One plain array per sub-array, named
`<base>_<polyvector>_<subtype>` (all lowercase), tagged with an annotation
that records its origin:

```modelica
polyvector Base[5] v = {A[3], B[2]};
// becomes:
A base_v_a[3] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
B base_v_b[2] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
```

Elements keep their declaration order: logical indices 1–3 live in
`base_v_a`, indices 4–5 in `base_v_b`. Every other rewrite is bookkeeping on
top of this layout: a logical index resolves to *(sub-array, local offset)*.

## Construct-by-construct

| PolyModelica | Lowers to |
| --- | --- |
| `polyvector Base[5] v = {A[3], B[2]}` | one annotated array per sub-array |
| `v[4].x` | `base_v_b[1].x` (index resolved statically) |
| `v.x` | `cat(1, base_v_a.x, base_v_b.x)` |
| `v[1:3].y` (LHS, literal RHS) | one split equation per sub-array |
| `v[2:4].y = u` (non-literal RHS) | `cat(1, base_v_a[2:3].y, base_v_b[1:1].y) = u` |
| `for s in v loop … end for` | one loop per sub-array, local range `1:n`, offsets added to other subscripts |
| `for i in 1:5 … v[i]` | range split at boundaries, global bounds kept, `base_v_b[i - 3]` |
| `{e(s) for s in v}` | unrolled array literal, one term per element |
| `s is A` / `isType` / `isSubtype` | folded to `true`/`false` per sub-array; only live branches emitted |
| `match s case …` | per-sub-array selection of the first matching case body |
| `size(v)`, `ndims(v)`, `numTypes(v)` | integer constants |
| `connect(c, v[1:4].p)` | one `connect` per sub-array with matching ranges |

The two iteration strategies are worth contrasting:

```modelica
// for s in v          → local ranges, offset on the OTHER arrays:
for s in 1:2 loop
  w[3 + s] = base_v_b[s].x;
end for;

// for i in 1:5, v[i]  → global ranges, offset on the POLYVECTOR access:
for i in 4:5 loop
  w[i] = base_v_b[i - 3].x;
end for;
```

## Dispatch compiles away

Type predicates and `match` never survive to runtime. The compiler knows the
concrete type of every element per sub-array, evaluates each predicate to a
constant, and emits only the surviving branch inside each per-sub-array loop:

```modelica
for s in v loop
  if s is A then w[s] = 2.0; else w[s] = 1.0; end if;
end for;
// becomes:
for s in 1:3 loop  w[s] = 2.0;     end for;   // A run
for s in 1:2 loop  w[3 + s] = 1.0; end for;   // B run
```

There is no runtime type tag, no branching cost, and no dead code in the
lowered model.

## Seeing it yourself

From a `.mos` script:

```modelica
setCommandLineOptions("--grammar=PolyModelica"); getErrorString();
loadFile("MyModel.mo"); getErrorString();
list(MyModel); getErrorString();
```

In OMEdit: right-click the class → **View Lowered Modelica**. Every
"Lowered Modelica" tab in this documentation was produced exactly this way.
