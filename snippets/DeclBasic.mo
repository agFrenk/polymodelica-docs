model DeclBasic
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

  polyvector Base[5] v = {A[3], B[2]};
  Real total;
equation
  total = sum(v.x);
end DeclBasic;
