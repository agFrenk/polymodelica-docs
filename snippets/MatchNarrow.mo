model MatchNarrow
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
    Real a = 1.5;
  equation
    x = 1.0;
  end A;

  model B
    extends Base;
    Real b = 2.5;
  equation
    x = 2.0;
  end B;

  polyvector Base[4] v = {A[2], B[2]};

  Real w[4];
equation
  for s in v loop
    match s
      case A: w[s] = s.a;
      case B: w[s] = s.b;
    end match;
  end for;
end MatchNarrow;
