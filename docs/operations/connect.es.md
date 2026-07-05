# Conectar slices

Cablear los conectores de un sub-rango de elementos contra un array de
conectores común con una sola ecuación `connect`.

## Sintaxis

```modelica
connect(c, v[a:b].puerto);           // lado común sin subíndice
connect(v[{1,3,5}].puerto, c[1:3]);  // o con un rango literal
```

Cualquier orden de argumentos funciona; el slice del polyvector puede ir
primero o segundo.

## Ejemplo

```modelica
connect(c1, v[1:4].p);
// se lowea a:
//   connect(c1[1:2], base_v_a[1:2].p);
//   connect(c1[3:4], base_v_b[1:2].p);
```

El slice se parte en los bordes de los sub-arrays y el lado común se parte
en sub-rangos correspondientes.

## Reglas

- Exactamente **un** lado puede ser un slice de sub-polyvector.
- El otro lado debe ser una **referencia a array común**: un nombre sin
  subíndice, o un nombre con un rango literal `a:b`.
- No permitido: conectar dos slices de sub-polyvector entre sí, o un lado
  común con subíndice vectorial como `c1[{1,2,3,4}]`.
- El subíndice del slice sigue las mismas reglas que cualquier slice de
  sub-rango ([Slicear un sub-rango](slice-range.md)).

Las formas rechazadas producen un error dedicado — mirá
[Errores y limitaciones](../errors.md#errores-de-slicing).
