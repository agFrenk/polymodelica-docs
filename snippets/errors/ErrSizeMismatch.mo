// expect-error: declares total size 4 but its sub-arrays sum to 5
model ErrSizeMismatch
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

  polyvector Base[4] v = {A[3], B[2]};   // 3 + 2 = 5, not 4
end ErrSizeMismatch;
