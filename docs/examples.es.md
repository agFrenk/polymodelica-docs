# Ejemplo: una economía en miniatura

Un modelo que usa la mayor parte del dialecto: una población de cinco
agentes — tres `Worker` y dos `Firm` — que acumulan riqueza de manera
distinta y pagan tasas de impuesto distintas. Compila, simula, y sus
resultados son fáciles de verificar a mano.

## El modelo

```modelica
--8<-- "Economy.mo"
```

Todo lo específico de PolyModelica en ~30 líneas:

- `partial model Agent` es el **tipo base**: el estado compartido `wealth`.
- `Worker` y `Firm` son **subtipos concretos** con su propia dinámica
  (crecimiento lineal vs. exponencial).
- `polyvector Agent[5] agents = {Worker[3], Firm[2]};` declara la población
  mixta.
- `sum(agents.wealth)` agrega sobre **todos** los agentes con un
  [field slice](language/access.md#field-slices-vfield).
- `for a in agents loop` + `match` aplica una tasa de impuesto por tipo con
  [despacho por tipo](language/type-dispatch.md) — 15% para workers, 30%
  para el resto.

## Lo que ve el compilador

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

El polyvector se convirtió en dos arrays vainilla; el slice en un `cat`; el
`for`+`match` en dos loops planos con las constantes de cada tipo ya
incorporadas. De acá en adelante es un modelo Modelica común.

## Simular

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

## Verificar los números a mano

Cada agente arranca con `wealth = 1`.

- Cada **Worker** crece linealmente: `der(wealth) = 0.6`, así que
  `wealth(10) = 1 + 0.6·10 = 7`. Tres workers aportan `21`.
- Cada **Firm** crece exponencialmente: `der(wealth) = 0.2·wealth`, así que
  `wealth(10) = e^{0.2·10} = e² ≈ 7.389`. Dos firms aportan `≈ 14.778`.

Totales en `t = 10`:

| Cantidad | Fórmula | Valor |
| --- | --- | --- |
| `totalWealth` | `3·7 + 2·e²` | `35.778…` ✓ |
| `taxRevenue` | `3·(0.15·7) + 2·(0.30·e²)` | `7.583…` ✓ |

La simulación coincide con la solución cerrada — el lowering preservó la
semántica del modelo exactamente.
