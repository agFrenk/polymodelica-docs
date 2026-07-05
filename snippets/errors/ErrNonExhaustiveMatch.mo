// expect-error: match is not exhaustive
model ErrNonExhaustiveMatch
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

  polyvector Base[4] v = {A[2], B[2]};

  Real w[4];
equation
  for s in v loop
    match s
      case A: w[s] = s.x;   // B is not covered and there is no otherwise
    end match;
  end for;
end ErrNonExhaustiveMatch;
