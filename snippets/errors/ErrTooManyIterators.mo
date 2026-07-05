// expect-error: at most 5 polyvectors
model ErrTooManyIterators
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

  polyvector Base[2] v = {A[1], B[1]};

  Real y[2, 2, 2, 2, 2, 2];
equation
  for a in v, b in v, c in v, d in v, e in v, f in v loop
    y[a, b, c, d, e, f] = a.x;
  end for;
end ErrTooManyIterators;
