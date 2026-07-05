model IterNested
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
  end A;

  model B
    extends Base;
  equation
    x = 2.0;
  end B;

  polyvector Base[2] v = {A[1], B[1]};

  Real y[2, 2];
equation
  // Equivalent to two physically nested for loops.
  for s in v, t in v loop
    y[s, t] = s.x * t.x;
  end for;
end IterNested;
