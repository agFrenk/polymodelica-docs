# Example: a small economy

One model that uses most of the dialect: a population of five agents — three
`Worker`s and two `Firm`s — that accumulate wealth differently and pay
different tax rates. It compiles, simulates, and its results are easy to
check by hand.

## The model

```modelica
--8<-- "Economy.mo"
```

Everything PolyModelica-specific in ~30 lines:

- `partial model Agent` is the **base type**: the shared state `wealth`.
- `Worker` and `Firm` are **concrete subtypes** with their own dynamics
  (linear growth vs. exponential growth).
- `polyvector Agent[5] agents = {Worker[3], Firm[2]};` declares the mixed
  population.
- `sum(agents.wealth)` aggregates over **all** agents with a
  [field slice](language/access.md#field-slices-vfield).
- `for a in agents loop` + `match` applies a per-type tax rate with
  [type dispatch](language/type-dispatch.md) — 15% for workers, 30%
  otherwise.

## What the compiler sees

```modelica
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

The polyvector became two vanilla arrays; the slice became a `cat`; the
`for`+`match` became two flat loops with the per-type constants baked in.
From here on this is a plain Modelica model.

## Simulating

```modelica
setCommandLineOptions("--grammar=PolyModelica"); getErrorString();
loadFile("Economy.mo"); getErrorString();
simulate(Economy, stopTime = 10); getErrorString();
val(totalWealth, 10);
val(taxRevenue, 10);
```

```
35.778363971872714
7.583509191561815
```

## Checking the numbers by hand

Every agent starts with `wealth = 1`.

- Each **Worker** grows linearly: `der(wealth) = 0.6`, so
  `wealth(10) = 1 + 0.6·10 = 7`. Three workers contribute `21`.
- Each **Firm** grows exponentially: `der(wealth) = 0.2·wealth`, so
  `wealth(10) = e^{0.2·10} = e^2 ≈ 7.389`. Two firms contribute `≈ 14.778`.

Totals at `t = 10`:

| Quantity | Formula | Value |
| --- | --- | --- |
| `totalWealth` | `3·7 + 2·e²` | `35.778…` ✓ |
| `taxRevenue` | `3·(0.15·7) + 2·(0.30·e²)` | `7.583…` ✓ |

The simulation matches the closed-form solution — the lowering preserved the
model's semantics exactly.
