# Despacho por tipo

Dentro de un `for s in v loop`, el tipo concreto de `s` se conoce por
sub-array. PolyModelica explota eso con tres predicados de tipo y una
construcción `match`. Todos se resuelven **estáticamente**: el compilador
elige la rama que es verdadera para cada sub-array y emite solo el código de
esa rama — sin tags de tipo en runtime, sin condicionales muertos.

## Predicados: `is`, `isType`, `isSubtype`

| Predicado | Verdadero cuando |
| --- | --- |
| `s is T` | el tipo concreto de `s` es exactamente `T` |
| `isType(s, T)` | igual que `s is T`, en forma de función |
| `isSubtype(s, T)` | el tipo concreto de `s` extiende `T` (o es `T`), directa o transitivamente |

Pueden aparecer en condiciones de `if`/`elseif`, combinarse con
`and`/`or`/`not`, e incluso usarse como valores booleanos al lado derecho de
una ecuación (donde se pliegan a `true`/`false` por sub-array). `isSubtype`
es lo que hace útiles como blanco de despacho a los niveles `partial`
intermedios de la jerarquía.

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

Fijate qué pasó: la cadena `if isType(s, A) / elseif isSubtype(s, Mid) /
else` desapareció. El loop de cada sub-array contiene solo la rama que le
corresponde.

### Estrechamiento de tipo

Dentro de una rama custodiada por un predicado, el iterador queda
**estrechado** al tipo testeado, así que los campos que solo existen en el
subtipo son accesibles:

```modelica
--8<-- "DispatchIs.mo"
```

`s.a` es legal en la rama `then` porque ahí se sabe que `s` es un `A`.

!!! info "`is` es una soft keyword"

    `is` solo actúa como operador en posición de condición. `Real is;` sigue
    siendo una declaración perfectamente legal, así que los modelos
    existentes que usan `is` como identificador siguen funcionando.

## `match` / `case` / `otherwise`

`match` despacha sobre el tipo concreto de un elemento. Viene en dos formas:
como **expresión** y como **ecuación** cuyos cases contienen ecuaciones
completas.

=== "PolyModelica"

    ```modelica
    --8<-- "DispatchMatch.mo"
    ```

=== "Modelica loweado"

    ```modelica
    Real rate[6];
    Real w[6];
    equation
      for s in 1:2 loop
        rate[s] = 1.0;
        w[s] = 0.10 * base_v_a[s].x;
      end for;
      for s in 1:2 loop
        rate[2 + s] = 1.2;
        w[2 + s] = 0.10 * base_v_b[s].x;
      end for;
      for s in 1:2 loop
        rate[4 + s] = 0.8;
        w[4 + s] = base_v_c[s].c;
      end for;
    ```

Selectores de case:

| Selector | Matchea |
| --- | --- |
| `case T:` | elementos de tipo concreto `T` |
| `case T1 \| T2:` | patrón OR: cualquiera de los dos tipos, un cuerpo compartido |
| `case isSubtype T:` | cualquier tipo que extienda `T` (ojo: sin paréntesis) |
| `otherwise:` | todo lo no matcheado arriba |

Semántica:

- **Gana el primer match.** Con cases superpuestos (`case C:` antes de
  `case isSubtype Mid:` donde `C extends Mid`), un elemento toma el primer
  case que lo matchea.
- **La exhaustividad se chequea.** Todo tipo concreto presente en el
  polyvector debe estar cubierto por algún case o por `otherwise:`; un tipo
  faltante es un error de compilación que nombra el tipo sin cubrir.
- Dentro del cuerpo de un case el elemento queda estrechado al tipo del
  case, exactamente igual que con los predicados.
