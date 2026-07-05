// expect-error: must be a literal range a:b
model ErrSteppedRange
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

  Real ws[3];
equation
  ws = v[1:2:6].w;   // stepped ranges are not allowed
end ErrSteppedRange;
