# Consultar el tipo de un elemento

Preguntar, dentro de un `for s in v loop`, qué es realmente un elemento, y
actuar según la respuesta. Los tests se resuelven **estáticamente**: el
compilador conoce el tipo concreto por sub-array, evalúa cada predicado a
una constante y emite solo la rama sobreviviente — sin tags de tipo en
runtime, sin condicionales muertos.

## Sintaxis

| Predicado | Verdadero cuando |
| --- | --- |
| `s is T` | el tipo concreto de `s` es exactamente `T` |
| `isType(s, T)` | igual que `s is T`, en forma de función |
| `isSubtype(s, T)` | el tipo concreto de `s` extiende `T` (o es `T`), directa o transitivamente |

Usables en condiciones de `if`/`elseif`, combinados con `and`/`or`/`not`, y
como valores booleanos al lado derecho de una ecuación (donde se pliegan a
`true`/`false` por sub-array). `isSubtype` es lo que hace útiles como blanco
de despacho a los niveles `partial` intermedios de la jerarquía.

## Ejemplo

=== "PolyModelica"

    ```modelica
    --8<-- "DispatchPredicates.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real w[6];
    Boolean q[6];
    equation
      for s in 1:2 loop
        w[s] = base_v_a[s].a;
        q[s] = false;
      end for;
      for s in 1:2 loop
        w[2 + s] = 0;
        q[2 + s] = false;
      end for;
      for s in 1:2 loop
        w[4 + s] = base_v_c[s].c;
        q[4 + s] = true;
      end for;
    ```

La cadena `if isType(s, A) / elseif isSubtype(s, Mid) / else` desapareció:
el loop de cada sub-array contiene solo la rama que le corresponde.

## Estrechamiento de tipo

Dentro de una rama custodiada por un predicado, el iterador queda
**estrechado** al tipo testeado, así que los campos que solo existen en el
subtipo son accesibles:

```modelica
--8<-- "DispatchIs.mo"
```

`s.a` es legal en la rama `then` porque ahí se sabe que `s` es un `A`.

## Reglas

!!! info "`is` es una soft keyword"

    `is` solo actúa como operador en posición de condición. `Real is;` sigue
    siendo una declaración perfectamente legal, así que los modelos
    existentes que usan `is` como identificador siguen funcionando.

- `isType` es exacto: un `C` que extiende `Mid` satisface
  `isSubtype(s, Mid)` pero no `isType(s, Mid)`.
- Estos mismos predicados son lo único aceptado como
  [filtros de comprehension](comprehend.md#filtrar-por-tipo).

## Relacionado

- [Despachar con match](match.md) — la versión de múltiples vías de esta
  operación
- [Iterar](iterate.md) — el loop en el que viven estos tests
