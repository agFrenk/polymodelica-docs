// expect-error: appears in more than one sub-array
model ErrDuplicateSubtype
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
  end A;

  polyvector Base[5] v = {A[3], A[2]};   // A listed twice
end ErrDuplicateSubtype;
