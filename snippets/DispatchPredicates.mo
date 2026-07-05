model DispatchPredicates
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
    Real b = 2.0;
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

  Real w[6];
  Boolean q[6];
equation
  for s in v loop
    if isType(s, A) then
      w[s] = s.a;
    elseif isSubtype(s, Mid) then
      w[s] = s.c;
    else
      w[s] = 0;
    end if;
    q[s] = isSubtype(s, Mid);   // folds to a constant per sub-array
  end for;
end DispatchPredicates;
