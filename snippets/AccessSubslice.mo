model AccessSubslice
  partial model Base
    Real x;
    Real y;
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

  model C
    extends Base;
  equation
    x = 3.0;
  end C;

  polyvector Base[6] v = {A[2], B[2], C[2]};

  Real ys[3];
equation
  // Contiguous range: elements 1..3 (crosses the A/B boundary).
  v[1:3].y = {1.5, 1.0, 0.9};
  // Strictly increasing index vector: one element per sub-array.
  ys = v[{1, 3, 5}].x;
  v[4:6].y = {0.5, 0.4, 0.3};
end AccessSubslice;
