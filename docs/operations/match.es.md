# Despachar con match

Darle a cada elemento un comportamiento por tipo en una sola construcción.
`match` despacha sobre el tipo concreto de un elemento y viene en dos
formas: como **expresión** y como **ecuación** cuyos cases contienen
ecuaciones completas. Igual que los [predicados de tipo](test-types.md), se
compila y desaparece por completo.

## Sintaxis

```modelica
// forma de expresión
x = match s
      case T1:    expr1;
      otherwise:  expr2;
    end match;

// forma de ecuación
match s
  case T1:            <ecuaciones>;
  case T2 | T3:       <ecuaciones>;
  case isSubtype T4:  <ecuaciones>;
  otherwise:          <ecuaciones>;
end match;
```

| Selector | Matchea |
| --- | --- |
| `case T:` | elementos de tipo concreto `T` |
| `case T1 \| T2:` | patrón OR: cualquiera de los dos tipos, un cuerpo compartido |
| `case isSubtype T:` | cualquier tipo que extienda `T` (ojo: sin paréntesis) |
| `otherwise:` | todo lo no matcheado arriba |

## Ejemplo

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

## Reglas

- **Gana el primer match.** Con cases superpuestos (`case C:` antes de
  `case isSubtype Mid:` donde `C extends Mid`), un elemento toma el primer
  case que lo matchea.
- **La exhaustividad se chequea.** Todo tipo concreto presente en el
  polyvector debe estar cubierto por algún case o por `otherwise:`; un tipo
  faltante es un error de compilación que nombra el tipo sin cubrir
  ([Errores y limitaciones](../errors.md#errores-de-despacho-e-iteracion)).
- Dentro del cuerpo de un case el elemento queda **estrechado** al tipo del
  case, exactamente igual que con los predicados — `s.c` es legal bajo
  `case isSubtype Mid:`.

## Relacionado

- [Consultar el tipo de un elemento](test-types.md) — `is`, `isType`,
  `isSubtype`
- [Iterar](iterate.md) — el loop en el que vive el `match`
