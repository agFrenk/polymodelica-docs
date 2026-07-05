# Comprehensions

Las comprehensions construyen arrays (o alimentan reducciones) a partir de
un polyvector, elemento a elemento, opcionalmente filtradas por tipo.

## Comprehensions de array y de reducción

```modelica
{expr(s) for s in v}          // array, una entrada por elemento
sum(expr(s) for s in v)       // reducción, también min/max/product
```

=== "PolyModelica"

    ```modelica
    --8<-- "CompBasic.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real xw[4];
    Real total;
    equation
      xw = {base_v_a[1].x*base_v_a[1].w, base_v_a[2].x*base_v_a[2].w,
            base_v_b[1].x*base_v_b[1].w, base_v_b[2].x*base_v_b[2].w};
      total = sum({base_v_a[1].x, base_v_a[2].x, base_v_b[1].x, base_v_b[2].x});
    ```

Las comprehensions se **desenrollan por completo** en la elaboración a
literales de array explícitos — un término por elemento, en orden lógico.
Funcionan en ecuaciones y en bindings (ecuaciones de declaración), p.ej.
`parameter Real sq[4] = {s.w * s.w for s in v};`.

## Filtros por predicado de tipo

Un filtro conserva solo los elementos que matchean un **predicado de tipo**:

```modelica
{expr(s) for s in v if <predicado>}
```

donde el predicado es `s is T`, `isType(s, T)` o `isSubtype(s, T)`,
posiblemente combinados con `and` / `or` / `not`
(mirá [Despacho por tipo](type-dispatch.md)).

=== "PolyModelica"

    ```modelica
    --8<-- "CompFilter.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real as[2];
    Real cs[2];
    Real xs[4];
    Real totalA;
    equation
      as = {base_v_a[1].a, base_v_a[2].a};
      cs = {base_v_c[1].c, base_v_c[2].c};
      xs = {base_v_a[1].x, base_v_a[2].x, base_v_b[1].x, base_v_b[2].x};
      totalA = sum({base_v_a[1].x, base_v_a[2].x});
    ```

Dos cosas para notar:

- **El largo del resultado es la cantidad de elementos que matchean**, no el
  tamaño del polyvector — `as` tiene 2 entradas, no 6. Como los filtros se
  resuelven en tiempo de compilación, el largo sigue siendo una constante de
  compilación.
- **El filtro estrecha el tipo del elemento en el cuerpo**: `s.a` es legal
  en la primera comprehension porque solo los elementos `A` sobreviven al
  filtro, y `s.c` en la segunda porque `isSubtype(s, Mid)` selecciona todo
  el subárbol debajo de `Mid`.

## Solo se permiten filtros de tipo

El filtro tiene que ser decidible por sub-array en tiempo de elaboración.
Una condición sobre **valores** de runtime se rechaza:

```modelica
bad = {s.x for s in v if s.x > 10};
// Error: a comprehension filter must be a type predicate
// (s is T, isType(s, T), isSubtype(s, T), combined with and/or/not)
```

Para selección dependiente de valores, calculá sobre el slice completo con
medios Modelica estándar (p.ej. `noEvent(if ... then ... else ...)` elemento
a elemento sobre `v.x`) o resolvelo dentro de un loop `for`.
