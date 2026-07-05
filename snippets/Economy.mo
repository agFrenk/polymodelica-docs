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
    der(wealth) = 0.2 * wealth;
  end Firm;

  polyvector Agent[5] agents = {Worker[3], Firm[2]};

  Real totalWealth;
  Real taxRevenue;
  Real tax[5];
equation
  totalWealth = sum(agents.wealth);
  for a in agents loop
    tax[a] = match a
               case Worker: 0.15 * a.wealth;
               otherwise:   0.30 * a.wealth;
             end match;
  end for;
  taxRevenue = sum(tax);
end Economy;
