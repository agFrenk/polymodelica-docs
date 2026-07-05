// expect-error: must be resolvable at elaboration
model ErrDynamicIndex
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
  end A;

  polyvector Base[2] v = {A[2]};

  Integer k;
  Real r;
equation
  k = 1;
  r = v[k].x;   // k is not a parameter/constant
end ErrDynamicIndex;
