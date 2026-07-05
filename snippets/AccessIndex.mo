model AccessIndex
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
    Real z = 4.0;
  equation
    x = 2.0;
  end B;

  polyvector Base[5] v = {A[3], B[2]};

  parameter Integer k = 2;
  Real r1, r2, r3, r4;
equation
  r1 = v[2].x;          // literal index
  r2 = v[k + 2].x;      // parameter expression, folded at elaboration
  r3 = v[end].x;        // end = last element
  r4 = v[1].x - v[4].z; // elements of different concrete types
end AccessIndex;
