# Iteración

Dos maneras de recorrer un polyvector: iterar los **elementos** directamente
(`for s in v`), o iterar un **rango numérico** e indexar (`v[i]`). Difieren
en qué es el iterador — una instancia vs. un entero — y en cómo se lowean.

## Iteración por elementos: `for s in v`

El iterador queda ligado a cada elemento por turno, con su tipo concreto
conocido por sub-array, así que el despacho por subtipo dentro del cuerpo
funciona (mirá [Despacho por tipo](type-dispatch.md)). Usado dentro de
subíndices de arrays, `s` actúa como el índice lógico del elemento.

=== "PolyModelica"

    ```modelica
    --8<-- "IterPolyFor.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real w[5];
    equation
      for s in 1:3 loop
        w[s] = base_v_a[s].x - base_v_a[s].z;
      end for;
      for s in 1:2 loop
        w[3 + s] = base_v_b[s].x - base_v_b[s].z;
      end for;
    ```

El loop se parte en un loop por sub-array. Cada uno corre sobre el rango
*local* `1:n`; los subíndices de otros arrays que usan el iterador reciben
el offset global del sub-array (`w[3 + s]`).

## Iteración numérica: `for i in 1:size(v)`

Un loop entero común cuyo cuerpo indexa el polyvector también funciona. El
rango se parte en los bordes de los sub-arrays; acá los rangos conservan sus
límites **globales** y el subíndice del polyvector es el que se re-basa:

=== "PolyModelica"

    ```modelica
    --8<-- "IterNumeric.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real w[5];
    equation
      for i in 1:3 loop
        w[i] = base_v_a[i].x;
      end for;
      for i in 4:5 loop
        w[i] = base_v_b[i - 3].x;
      end for;
    ```

Un rango no tiene que cubrir todo el vector ni alinearse con los bordes de
los sub-arrays — `for i in 2:4 loop` sobre `{A[3], B[2]}` se parte en `2:3`
y `4:4`.

## Loops anidados y multi-iterador

Los iteradores de polyvector componen: las cadenas de iteradores separados
por coma y los loops físicamente anidados son equivalentes y ambos producen
la expansión cartesiana completa, un nido de loops por combinación de
sub-arrays. Los iteradores pueden recorrer el mismo polyvector o distintos,
y los iteradores numéricos y de polyvector se mezclan libremente en
cualquier nivel de anidamiento.

=== "PolyModelica"

    ```modelica
    --8<-- "IterNested.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real y[2, 2];
    equation
      for s in 1:1 loop
        for t in 1:1 loop
          y[s, t] = base_v_a[s].x * base_v_a[t].x;
        end for;
        for t in 1:1 loop
          y[s, 1 + t] = base_v_a[s].x * base_v_b[t].x;
        end for;
      end for;
      for s in 1:1 loop
        for t in 1:1 loop
          y[1 + s, t] = base_v_b[s].x * base_v_a[t].x;
        end for;
        for t in 1:1 loop
          y[1 + s, 1 + t] = base_v_b[s].x * base_v_b[t].x;
        end for;
      end for;
    ```

!!! warning "Como máximo 5 iteradores de polyvector por cadena de for"

    El lowering multiplica las combinaciones de sub-arrays, así que el
    código generado crece con el producto cartesiano. Una única cadena de
    for puede iterar sobre a lo sumo **5** polyvectors; un sexto es un error
    de compilación.

## Notas

- Todas las formas de arriba son construcciones de sección de ecuaciones
  (ahí es donde las ejercita la test suite del dialecto).
- Un sub-array vacío (`A[0]`) se lowea a un loop `1:0`, que simplemente
  itera cero veces.
- Para construir arrays en vez de escribir ecuaciones por elemento, mirá
  [Comprehensions](comprehensions.md).
