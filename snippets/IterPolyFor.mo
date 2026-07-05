model IterPolyFor
  partial model Base
    Real x;
    Real z;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
    z = 0.1;
  end A;

  model B
    extends Base;
  equation
    x = 2.0;
    z = 0.2;
  end B;

  polyvector Base[5] v = {A[3], B[2]};

  Real w[5];
equation
  for s in v loop
    w[s] = s.x - s.z;
  end for;
end IterPolyFor;
