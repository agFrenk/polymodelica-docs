# Errores y limitaciones

PolyModelica hace cumplir sus restricciones con errores de compilación
dedicados, todos con el prefijo `PolyModelica:`. Esta página lista cada uno,
qué lo dispara y cómo arreglarlo — seguido de las limitaciones conocidas de
la implementación actual.

## Errores de declaración

**Subtipo duplicado**

```modelica
polyvector Base[5] v = {A[3], A[2]};
```
> PolyModelica: type A appears in more than one sub-array of polyvector v;
> group same-type elements into a single Type[N] declaration.

Arreglo: `{A[5]}`.

**Tamaños que no coinciden**

```modelica
polyvector Base[4] v = {A[3], B[2]};
```
> PolyModelica: polyvector v declares total size 4 but its sub-arrays sum
> to 5.

Arreglo: corregí el total, u omitilo y dejá que se infiera
(`polyvector Base v = ...`).

**Un subtipo no deriva del base**

```modelica
polyvector Base[2] v = {A[1], Other[1]};   // Other no extiende Base
```
> PolyModelica: type Other of polyvector v is not derived from its base type
> Base. A sub-array type must extend Base, directly or transitively.

A diferencia de los otros, este se reporta cuando el modelo se *chequea*
(viene del chequeo nominal de subtipos del front end), no al cargar.

## Errores de indexación

**Índice dinámico**

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

**Fuera de rango**

```modelica
r = v[5].x;   // v tiene 2 elementos
```
> PolyModelica: index 5 is out of range for polyvector v, which has 2
> element(s).

## Errores de slicing

El subíndice de un slice de sub-polyvector `v[...].field` debe ser un rango
literal `a:b` (`a <= b`, al menos dos elementos) o un vector estrictamente
creciente de literales enteros.

| Disparador | Error |
| --- | --- |
| `v[3:3].w` | *the sub-polyvector subscript of v selects a single element. Use v[i] directly…* |
| `v[3:2].w` | *the sub-polyvector subscript of v selects no elements; an empty sub-polyvector is not allowed.* |
| `v[1:2:6].w`, `v[{3,1,5}].w`, `v[k:k+2].w` | *the sub-polyvector subscript of v must be a literal range a:b (a <= b) or a strictly increasing vector of integer literals {i1, ..., ik}. Stepped ranges, parametric bounds and non-literal entries are not allowed.* |
| `v[2:8].w` (tamaño 6) | *index 7 is out of range for polyvector v, which has 6 element(s).* |

**Restricciones de connect**

```modelica
connect(v1[1:4].p, v2[1:4].p);        // dos lados poly
connect(v[1:4].p, c1[{1,2,3,4}]);     // lado común con subíndice vectorial
```
> PolyModelica: a connect with a sub-polyvector slice must have exactly one
> sub-polyvector side, connected to a plain array reference (an unsubscripted
> name or a name with a literal range subscript a:b). Connecting two
> sub-polyvectors, or to a vector-subscripted reference, is not supported.

## Errores de despacho e iteración

**Match no exhaustivo**

```modelica
match s
  case A: w[s] = s.x;   // el polyvector también contiene B
end match;
```
> PolyModelica: match is not exhaustive; the concrete type B is not covered
> by any case. Add a case for it or an 'otherwise:' branch.

**Demasiados iteradores de polyvector**

```modelica
for a in v, b in v, c in v, d in v, e in v, f in v loop
```
> PolyModelica: a for-chain may iterate over at most 5 polyvectors (the
> cartesian product blows up); found 6 nested polyvector iterators.

Cinco está bien; seis no.

**Filtro de comprehension basado en valores**

```modelica
bad = {s.x for s in v if s.x > 10};
```
> PolyModelica: a comprehension filter must be a type predicate (s is T,
> isType(s, T), isSubtype(s, T), combined with and/or/not) that resolves per
> sub-array at elaboration; value conditions are not allowed.

## Limitaciones conocidas

### OMEdit y la edición gráfica

OMEdit regenera el texto fuente de una clase desde la symbol table del
compilador — que guarda el programa **loweado** — cada vez que necesita
reescribir el archivo. En la práctica:

- **Seguro:** editar tu modelo en la *vista de texto* y guardar.
- **No seguro:** guardar después de una edición *gráfica* (dibujar en las
  vistas Icon/Diagram, cambiar valores por diálogos). Eso reescribe el `.mo`
  con el código loweado, y tus declaraciones `polyvector` quedan
  reemplazadas por los arrays generados.

Mantené los fuentes PolyModelica bajo control de versiones, y tratá las
ediciones gráficas como exploración de solo lectura. (Verificado
empíricamente sobre el fork actual.)

### Indexar dentro de un field slice (BUG-1)

`v.field[i]` — la vía de escape documentada para indexación dinámica —
actualmente produce un lowering incorrecto. La propia test suite del
compilador lo registra como test known-failing (BUG-1). Workarounds: iterá
con `for s in v loop`, o ligá el slice a un array primero
(`Real xs[size(v)] = v.x;`) e indexá ese.

### Alcance de las construcciones

Las formas de iteración, despacho y comprehension están especificadas (y
testeadas) como construcciones de **sección de ecuaciones**. El uso en
secciones de algoritmo no forma parte de la superficie de tests actual.
