# PolyModelica

PolyModelica es un dialecto de [Modelica](https://modelica.org/) que agrega
**arrays polimórficos** al lenguaje. Está implementado como fork de
[OpenModelica](https://openmodelica.org/) y se habilita con un único flag del
compilador: `--grammar=PolyModelica`.

## El problema

Los arrays de Modelica son homogéneos: todos los elementos de
`Agent agents[5]` tienen exactamente el mismo tipo. Modelar una población de
componentes *distintos pero emparentados* — trabajadores y empresas, varios
tipos de carga sobre un mismo bus, flotas mixtas de vehículos — te obliga a
declarar un array por tipo concreto y duplicar cada ecuación que recorre
"todos", o a aplanar la jerarquía en flags y condicionales.

## La idea

Un **polyvector** es un array cuyo tipo declarado es un `partial model` y
cuyos elementos son instancias de subtipos concretos:

```modelica
polyvector Agent[5] agents = {Worker[3], Firm[2]};
```

`agents` se comporta como un único vector de cinco elementos. Sobre eso, el
dialecto ofrece:

| Operación | Ejemplo | |
| --- | --- | --- |
| Proyectar un campo | `sum(agents.wealth)` | [Proyectar un campo](operations/project-field.md) |
| Indexar un elemento | `agents[4].wealth` | [Indexar un elemento](operations/index-element.md) |
| Slicear un sub-rango | `agents[1:3].y` | [Slicear un sub-rango](operations/slice-range.md) |
| Iterar | `for a in agents loop … end for` | [Iterar](operations/iterate.md) |
| Consultar el tipo | `a is Worker`, `isSubtype(a, Mid)` | [Consultar el tipo de un elemento](operations/test-types.md) |
| Despachar con match | `match a case Worker: … end match` | [Despachar con match](operations/match.md) |
| Construir arrays | `{a.wealth for a in agents if a is Worker}` | [Comprehensions](operations/comprehend.md) |

## Un ejemplo completo

El modelo de la izquierda es PolyModelica válido. La pestaña derecha muestra
con qué trabaja realmente el compilador — Modelica 100% estándar:

=== "PolyModelica"

    ```modelica
    --8<-- "Economy.mo"
    ```

=== "Modelica loweado"

    ```modelica
    model Economy
      partial model Agent
        Real wealth(start = 1.0);
      end Agent;

      model Worker
        extends Agent;
      equation
        der(wealth) = 0.6;
      end Worker;

      model Firm
        extends Agent;
      equation
        der(wealth) = 0.2*wealth;
      end Firm;

      Worker agent_agents_worker[3] annotation(
        __PolyModelica(polyvector = "agents", baseType = "Agent"));
      Firm agent_agents_firm[2] annotation(
        __PolyModelica(polyvector = "agents", baseType = "Agent"));
      Real totalWealth;
      Real taxRevenue;
      Real tax[5];
    equation
      totalWealth = sum(cat(1, agent_agents_worker.wealth, agent_agents_firm.wealth));
      for a in 1:3 loop
        tax[a] = 0.15*agent_agents_worker[a].wealth;
      end for;
      for a in 1:2 loop
        tax[3 + a] = 0.30*agent_agents_firm[a].wealth;
      end for;
      taxRevenue = sum(tax);
    end Economy;
    ```

Este modelo compila, simula y da `totalWealth(10) = 35.78`,
`taxRevenue(10) = 7.58` — mirá el [walkthrough completo](examples.md).

## Cómo funciona

PolyModelica es un **lowering en tiempo de parseo**: justo después de
parsear, un paso de elaboración reescribe cada construcción PolyModelica a
Modelica vainilla, antes de que corra cualquier otra etapa del compilador. El
resto del compilador — flattening, procesamiento simbólico, generación de
código, simulación — nunca ve un polyvector.

Consecuencias con las que podés contar:

- Todo lo que viene después (solvers, ploteo, export FMI) funciona sin
  cambios.
- `list(Modelo)` y *View Lowered Modelica* de OMEdit te muestran exactamente
  en qué se convirtió tu modelo — el lowering es totalmente inspeccionable.
- El código loweado lleva annotations `__PolyModelica(...)`, así que el
  origen de cada array generado es rastreable.

La página de [Lowering](lowering.md) documenta en qué se convierte cada
construcción.

!!! note "Estado del proyecto"

    PolyModelica es un dialecto de investigación desarrollado como parte de
    una tesis de ingeniería, implementado sobre un fork de OpenModelica.
    Todos los ejemplos de código de esta documentación fueron validados
    contra el compilador real antes de publicarse.
