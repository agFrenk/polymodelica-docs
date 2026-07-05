model CompBasic
  partial model Base
    Real x;
    Real w;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
    w = 0.5;
  end A;

  model B
    extends Base;
  equation
    x = 2.0;
    w = 0.25;
  end B;

  polyvector Base[4] v = {A[2], B[2]};

  Real xw[4];
  Real total;
equation
  xw = {s.x * s.w for s in v};      // array comprehension
  total = sum(s.x for s in v);      // reduction comprehension
end CompBasic;
