// expect-error: selects a single element
model ErrSingleElementSlice
  partial model Base
    Real w;
  end Base;

  model A
    extends Base;
  equation
    w = 1.0;
  end A;

  model B
    extends Base;
  equation
    w = 2.0;
  end B;

  polyvector Base[6] v = {A[3], B[3]};

  Real ws[1];
equation
  ws = v[3:3].w;   // use v[3].w instead
end ErrSingleElementSlice;
