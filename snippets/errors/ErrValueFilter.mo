// expect-error: a comprehension filter must be a type predicate
model ErrValueFilter
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

  polyvector Base[4] v = {A[2], B[2]};

  Real bad[4];
equation
  bad = {s.x for s in v if s.x > 10};   // value conditions are not allowed
end ErrValueFilter;
