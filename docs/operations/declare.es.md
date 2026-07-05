# Declarar un polyvector

Crear un único array que contiene instancias de *distintos* subtipos
concretos de un `partial model` común.

## Sintaxis

```modelica
polyvector Base[N] nombre = {Tipo1[n1], Tipo2[n2], ...};
polyvector Base nombre = {Tipo1[n1], Tipo2[n2], ...};   // N inferido
```

- `Base` — el **tipo base**: un `partial model` que declara lo que todos los
  elementos comparten (variables, parámetros, conectores).
- `TipoK` — un **subtipo concreto**: un modelo que hace `extends Base`,
  directa o transitivamente.
- `TipoK[nK]` — un **sub-array**: `nK` elementos consecutivos de ese tipo.
- `N` — el tamaño total; debe ser igual a `n1 + n2 + ...`, o se puede
  omitir.

## Ejemplo

=== "PolyModelica"

    ```modelica
    --8<-- "DeclBasic.mo"
    ```

=== "Modelica loweado"

    ```modelica
    A base_v_a[3] annotation(
      __PolyModelica(polyvector = "v", baseType = "Base"));
    B base_v_b[2] annotation(
      __PolyModelica(polyvector = "v", baseType = "Base"));
    Real total;
    equation
      total = sum(cat(1, base_v_a.x, base_v_b.x));
    ```

Cada sub-array se lowea a un array Modelica común etiquetado con una
annotation `__PolyModelica` (mirá [Lowering](../lowering.md)).

Con el tamaño omitido, se infiere de los sub-arrays (acá 2 + 1 = 3):

```modelica
--8<-- "DeclInferred.mo"
```

## Disposición de los elementos

Los elementos son contiguos, en orden de declaración. Para
`polyvector Base[5] v = {A[3], B[2]}`:

| Índice lógico | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- |
| Tipo concreto | A | A | A | B | B |

El índice lógico es el que usás en todos lados — `v[4]` es el primer
elemento `B`. El compilador traduce índices lógicos al sub-array y offset
correctos en tiempo de elaboración.

## Reglas

- **Un sub-array por subtipo.** El mismo tipo concreto no puede aparecer dos
  veces; agrupá sus elementos en una única entrada `Tipo[n]`.
- **Todo subtipo debe derivar del base**, directamente o a través de modelos
  intermedios (posiblemente parciales).
- **El tamaño declarado debe coincidir** con la suma de los sub-arrays
  cuando se indica.
- **Los sub-arrays vacíos son válidos**: `{A[0], B[2]}` funciona, y los
  loops sobre el tramo vacío simplemente iteran cero veces.
- Un modelo puede declarar **varios polyvectors**, incluso sobre el mismo
  tipo base.

Las violaciones son errores de compilación con mensajes dedicados — mirá
[Errores y limitaciones](../errors.md#errores-de-declaracion).

## Relacionado

- [Consultar tamaño y tipos](cardinality.md) — `size(v)`, `numTypes(v)`
- [Indexar un elemento](index-element.md) — `v[i]`
- [Iterar](iterate.md) — `for s in v loop`
