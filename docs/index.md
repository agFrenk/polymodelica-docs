# PolyModelica

PolyModelica is a dialect of [Modelica](https://modelica.org/) that adds
**polymorphic arrays** to the language. It is implemented as a fork of
[OpenModelica](https://openmodelica.org/) and is enabled with a single
compiler flag: `--grammar=PolyModelica`.

## The problem

Modelica arrays are homogeneous: every element of `Agent agents[5]` has the
exact same type. Modeling a population of *different but related* components —
workers and firms, several kinds of loads on one bus, mixed vehicle fleets —
forces you to either declare one array per concrete type and duplicate every
equation that ranges over "all of them", or flatten the hierarchy into flags
and conditionals.

## The idea

A **polyvector** is an array whose declared type is a `partial model` and
whose elements are instances of concrete subtypes:

```modelica
polyvector Agent[5] agents = {Worker[3], Firm[2]};
```

`agents` behaves as one five-element vector. On top of it the dialect gives
you:

| Operation | Example | |
| --- | --- | --- |
| Project a field | `sum(agents.wealth)` | [Project a field](operations/project-field.md) |
| Index an element | `agents[4].wealth` | [Index an element](operations/index-element.md) |
| Slice a sub-range | `agents[1:3].y` | [Slice a sub-range](operations/slice-range.md) |
| Iterate | `for a in agents loop … end for` | [Iterate](operations/iterate.md) |
| Test an element's type | `a is Worker`, `isSubtype(a, Mid)` | [Test an element's type](operations/test-types.md) |
| Dispatch with match | `match a case Worker: … end match` | [Dispatch with match](operations/match.md) |
| Build arrays | `{a.wealth for a in agents if a is Worker}` | [Comprehensions](operations/comprehend.md) |

## A complete example

The model on the left is legal PolyModelica. The right tab shows what the
compiler actually works with — plain, 100% standard Modelica:

=== "PolyModelica"

    ```modelica
    --8<-- "Economy.mo"
    ```

=== "Lowered Modelica"

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

This model compiles, simulates, and produces `totalWealth(10) = 35.78`,
`taxRevenue(10) = 7.58` — see the [full walkthrough](examples.md).

## How it works

PolyModelica is a **parse-time lowering**: right after parsing, an elaboration
pass rewrites every PolyModelica construct into vanilla Modelica, before any
other compiler stage runs. The rest of the compiler — flattening, symbolic
processing, code generation, simulation — never sees a polyvector.

Consequences you can rely on:

- Everything downstream (solvers, plotting, FMI export) works unchanged.
- `list(Model)` and OMEdit's *View Lowered Modelica* show you exactly what
  your model became — the lowering is fully inspectable.
- Lowered code carries `__PolyModelica(...)` annotations, so the origin of
  every generated array is traceable.

The [Lowering](lowering.md) page documents what each construct turns into.

!!! note "Project status"

    PolyModelica is a research dialect developed as part of an engineering
    thesis, implemented on a fork of OpenModelica. Every code example in this
    documentation was validated against the actual compiler before
    publication.
