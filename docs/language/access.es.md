# Acceso y slicing

Tres maneras de leer (y escribir) el contenido de un polyvector: indexar un
elemento individual, proyectar un campo sobre todos los elementos, y hacer
slicing de un sub-rango.

## Indexación: `v[i]`

`v[i]` denota el elemento i-ésimo (índice lógico, empezando en 1) con su
tipo **concreto**, así que los campos que solo existen en el subtipo son
accesibles. Funciona a ambos lados de una ecuación.

=== "PolyModelica"

    ```modelica
    --8<-- "AccessIndex.mo"
    ```

=== "Modelica loweado"

    ```modelica
    parameter Integer k = 2;
    Real r1, r2, r3, r4;
    equation
      r1 = base_v_a[2].x;
      r2 = base_v_b[1].x;
      r3 = base_v_b[2].x;
      r4 = base_v_a[1].x - base_v_b[1].z;
    ```

El índice debe ser **resoluble en tiempo de elaboración**: un literal
entero, un `parameter`/`constant`, o una expresión sobre ellos (`+`, `-`,
`*` y `/` entera se pliegan; `end` también funciona). El compilador resuelve
el índice a un sub-array y offset, y chequea los límites, en tiempo de
compilación.

Un índice que recién se conoce en runtime se rechaza:

```modelica
Integer k;
equation
  k = 1;
  r = v[k].x;   // Error: el índice debe resolverse en la elaboración
```

El propio mensaje de error nombra las dos alternativas para acceso dinámico:
iterar con `for s in v loop` ([Iteración](iteration.md)), o proyectar
primero un campo e indexar el array común resultante (`v.x[i]`, abajo).

## Field slices: `v.field`

`v.field` proyecta un campo sobre todo el polyvector, dando un array común
de largo `size(v)`. Es el caballito de batalla de las ecuaciones agregadas.
Los slices soportan:

- reducciones: `sum`, `product`, `min`, `max`,
- aritmética elemento a elemento entre slices (`v.x .* v.w`) y con
  escalares,
- built-ins matemáticos elemento a elemento (`abs`, `sqrt`, `exp`, `sin`,
  ...),
- slices booleanos con `and` / `or` / `not`,
- `der()` sobre un slice: `der(v.x) = {1.0, 2.0, 3.0};`,
- consultas de forma: `size(v.x, 1)`, `ndims(v.x)`,
- caminos de componentes anidados: `v.part.x` cuando `Base` contiene un
  componente `part`.

=== "PolyModelica"

    ```modelica
    --8<-- "AccessSlice.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real total;
    Real peak;
    Real weighted[4];
    Real scaled[4];
    equation
      total = sum(cat(1, base_v_a.x, base_v_b.x));
      peak = max(cat(1, base_v_a.x, base_v_b.x));
      weighted = cat(1, base_v_a.x, base_v_b.x) .* cat(1, base_v_a.w, base_v_b.w);
      scaled = 2.0 * cat(1, base_v_a.x, base_v_b.x);
    ```

Un slice se lowea a `cat(1, ...)` sobre los arrays por subtipo; cada
aparición de un slice en una expresión recibe su propio `cat`.

!!! bug "Problema conocido: indexar dentro de un field slice"

    `v.field[i]` — proyectar primero y después indexar con un `i` dinámico —
    es la vía de escape pensada para índices en runtime, pero actualmente se
    lowea mal (registrado como BUG-1 en la test suite del compilador). Hasta
    que se arregle, preferí `for s in v loop` o copiá el slice a un array
    declarado primero: `Real xs[size(v)] = v.x;` y después indexá `xs[i]`.

## Slices de sub-polyvector: `v[rango].field`

Una selección contigua o estrictamente creciente de elementos se puede
slicear y proyectar en un solo paso, a cualquiera de los dos lados de una
ecuación:

=== "PolyModelica"

    ```modelica
    --8<-- "AccessSubslice.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real ys[3];
    equation
      base_v_a[1:2].y = {1.5, 1.0};
      base_v_b[1:1].y = {0.9};
      ys = cat(1, base_v_a[1:1].x, base_v_b[1:1].x, base_v_c[1:1].x);
      base_v_b[2:2].y = {0.5};
      base_v_c[1:2].y = {0.4, 0.3};
    ```

Un slice que abarca varios sub-arrays se parte en los bordes; cuando el lado
derecho es un literal de array, el literal se parte elemento a elemento, y
si no, el lado izquierdo se convierte en una ecuación
`cat(1, ...) = rhs`.

El subíndice debe ser:

- un **rango literal** `a:b` con `a <= b`, que seleccione al menos dos
  elementos, o
- un **vector estrictamente creciente de literales enteros** `{i1, ..., ik}`.

Todo lo demás se rechaza con un error de compilación: rangos de un solo
elemento (`v[3:3]` — usá `v[3]`), rangos vacíos, rangos con paso
(`v[1:2:6]`), vectores no crecientes, límites paramétricos (`v[k:k+2]`) e
índices fuera de rango. Mirá
[Errores y limitaciones](../errors.md#errores-de-slicing).

## `connect` con slices

Un slice de sub-polyvector puede ser un lado de un `connect`; el otro lado
debe ser una referencia a array común (sin subíndice, o con un rango
literal):

```modelica
connect(c1, v[1:4].p);
// se lowea a:
//   connect(c1[1:2], base_v_a[1:2].p);
//   connect(c1[3:4], base_v_b[1:2].p);
```

Conectar dos slices de sub-polyvector entre sí, o contra una referencia con
subíndice vectorial como `c1[{1,2,3}]`, no está soportado.
