model DispatchIs
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
    Real a = 1.0;
  equation
    x = 1.0;
  end A;

  model B
    extends Base;
    Real b = 2.0;
  equation
    x = 2.0;
  end B;

  polyvector Base[4] v = {A[2], B[2]};

  Real w[4];
equation
  for s in v loop
    if s is A then
      w[s] = s.a;       // s is narrowed to A here
    elseif s is B then
      w[s] = s.b;       // and to B here
    end if;
  end for;
end DispatchIs;
