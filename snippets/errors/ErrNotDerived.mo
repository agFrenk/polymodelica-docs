// expect-error: is not derived from its base type
model ErrNotDerived
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
  end A;

  model Other      // does NOT extend Base
    Real y = 1.0;
  end Other;

  polyvector Base[2] v = {A[1], Other[1]};
end ErrNotDerived;
