model DeclCardinality
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

  model C
    extends Base;
  equation
    x = 3.0;
  end C;

  polyvector Base[5] v = {A[2], B[2], C[1]};

  constant Integer total = size(v);       // 5: number of elements
  constant Integer dims  = ndims(v);      // 1: polyvectors are one-dimensional
  constant Integer types = numTypes(v);   // 3: number of sub-arrays

  // Cardinality builtins can be used as dimensions:
  parameter Real weight[numTypes(v)] = {0.5, 0.3, 0.2};
  Real xs[size(v)];
equation
  for k in 1:size(v) loop
    xs[k] = v[k].x;
  end for;
end DeclCardinality;
