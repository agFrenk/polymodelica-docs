model IterNumeric
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

  Real w[5];
equation
  for i in 1:size(v) loop
    w[i] = v[i].x;
  end for;
end IterNumeric;
