# Slicear un sub-rango

Seleccionar un subconjunto de elementos y proyectar un campo sobre él, en un
solo paso, a cualquiera de los dos lados de una ecuación.

## Sintaxis

```modelica
v[a:b].campo             // rango literal, a <= b, al menos dos elementos
v[{i1, i2, ...}].campo   // vector estrictamente creciente de literales enteros
```

## Ejemplo

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

Un slice que abarca varios sub-arrays se parte en los bordes. Cuando el lado
derecho es un literal de array, el literal se parte elemento a elemento; si
no, el lado izquierdo se convierte en una única ecuación
`cat(1, ...) = rhs`.

## Reglas

El subíndice debe ser:

- un **rango literal** `a:b` con `a <= b`, que seleccione al menos dos
  elementos, o
- un **vector estrictamente creciente de literales enteros**
  `{i1, ..., ik}`.

Todo lo demás es un error de compilación:

| Rechazado | Por qué |
| --- | --- |
| `v[3:3].w` | un solo elemento — usá `v[3].w` |
| `v[3:2].w` | selección vacía |
| `v[1:2:6].w` | rango con paso |
| `v[{3,1,5}].w` | no estrictamente creciente |
| `v[k:k+2].w` | límites paramétricos |
| `v[2:8].w` sobre tamaño 6 | fuera de rango |

Mirá [Errores y limitaciones](../errors.md#errores-de-slicing) para los
mensajes exactos.

## Relacionado

- [Indexar un elemento](index-element.md) — un solo elemento, `v[i]`
- [Proyectar un campo](project-field.md) — el vector completo, `v.campo`
- [Conectar slices](connect.md) — slices como argumentos de `connect`
