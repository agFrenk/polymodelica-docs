model AccessSlice
  partial model Base
    Real x;
    Real w;
  end Base;

  model A
    extends Base;
  equation
    x = 1.0;
    w = 0.5;
  end A;

  model B
    extends Base;
  equation
    x = 2.0;
    w = 0.25;
  end B;

  polyvector Base[4] v = {A[2], B[2]};

  Real total;
  Real peak;
  Real weighted[4];
  Real scaled[4];
equation
  total = sum(v.x);            // reduction over a field slice
  peak = max(v.x);
  weighted = v.x .* v.w;       // element-wise ops between two slices
  scaled = 2.0 * v.x;          // scalar arithmetic on a slice
end AccessSlice;
