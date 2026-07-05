// expect-error: is out of range for polyvector
model ErrOutOfRange
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
  end A;

  polyvector Base[2] v = {A[2]};

  Real r;
equation
  r = v[5].x;   // v only has 2 elements
end ErrOutOfRange;
