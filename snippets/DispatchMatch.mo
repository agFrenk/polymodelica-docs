model DispatchMatch
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

  partial model Mid
    extends Base;
    Real c = 3.0;
  end Mid;

  model C
    extends Mid;
  equation
    x = 3.0;
  end C;

  polyvector Base[6] v = {A[2], B[2], C[2]};

  Real rate[6];
  Real w[6];
equation
  for s in v loop
    rate[s] = match s
                case A:    1.0;
                case B:    1.2;
                otherwise: 0.8;
              end match;

    match s
      case A | B:         w[s] = 0.10 * s.x;
      case isSubtype Mid: w[s] = s.c;
    end match;
  end for;
end DispatchMatch;
