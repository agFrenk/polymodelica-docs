model DeclInferred
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

  // No total size: it is inferred from the sub-arrays (2 + 1 = 3).
  polyvector Base v = {A[2], B[1]};
  Real total;
equation
  total = sum(v.x);
end DeclInferred;
