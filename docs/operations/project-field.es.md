# Proyectar un campo

Tomar un campo sobre **todos** los elementos de un polyvector a la vez, como
un array común de largo `size(v)`. Es el caballito de batalla de las
ecuaciones agregadas como `sum(agents.wealth)`.

## Sintaxis

```modelica
v.campo            // array común, largo size(v)
v.parte.campo      // los caminos de componentes anidados también funcionan
```

## Ejemplo

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

Un campo proyectado se lowea a `cat(1, ...)` sobre los arrays por subtipo;
cada aparición en una expresión recibe su propio `cat`.

## Qué podés hacer con un campo proyectado

- reducciones: `sum`, `product`, `min`, `max`,
- aritmética elemento a elemento entre proyecciones (`v.x .* v.w`) y con
  escalares,
- built-ins matemáticos elemento a elemento (`abs`, `sqrt`, `exp`, `sin`,
  ...),
- campos booleanos con `and` / `or` / `not`,
- `der()` sobre la proyección: `der(v.x) = {1.0, 2.0, 3.0};`,
- consultas de forma: `size(v.x, 1)`, `ndims(v.x)`,
- bindings (ecuaciones de declaración): `Real xs[size(v)] = v.x;`.

## Reglas

!!! bug "Problema conocido: indexar dentro de una proyección"

    `v.campo[i]` — proyectar primero y después indexar con un `i` dinámico —
    es la vía de escape pensada para índices en runtime, pero actualmente se
    lowea mal (registrado como BUG-1 en la test suite del compilador). Hasta
    que se arregle, preferí `for s in v loop` ([Iterar](iterate.md)) o copiá
    la proyección a un array declarado primero:
    `Real xs[size(v)] = v.x;` y después indexá `xs[i]`.

## Relacionado

- [Slicear un sub-rango](slice-range.md) — proyectar solo parte del vector
- [Construir arrays (comprehensions)](comprehend.md) — expresiones por
  elemento
