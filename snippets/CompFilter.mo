model CompFilter
  partial model Base
    Real x;
  end Base;

  model A
    extends Base;
    Real a = 1.0;
  equation
    x = 1.0;
  end A;

  model B
    extends Base;
  equation
    x = 2.0;
  end B;

  partial model Mid
    extends Base;
    Real c = 3.0;
  end Mid;

  model C
    extends Mid;
  equation
    x = 3.0;
  end C;

  polyvector Base[6] v = {A[2], B[2], C[2]};

  Real as[2];
  Real cs[2];
  Real xs[4];
  Real totalA;
equation
  as = {s.a for s in v if s is A};              // narrows s to A in the body
  cs = {s.c for s in v if isSubtype(s, Mid)};   // selects the whole Mid subtree
  xs = {s.x for s in v if s is A or s is B};    // predicates combine with and/or/not
  totalA = sum(s.x for s in v if s is A);       // filtered reduction
end CompFilter;
