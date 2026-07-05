# Getting started

PolyModelica lives in a fork of OpenModelica. Both the command-line compiler
(`omc`) and the graphical editor (OMEdit) support the dialect once you enable
the PolyModelica grammar.

## Enabling the dialect

The dialect is off by default. The compiler behaves as stock OpenModelica
until you select the PolyModelica grammar:

=== "omc scripts (.mos)"

    ```modelica
    setCommandLineOptions("--grammar=PolyModelica");
    ```

=== "omc command line"

    ```bash
    omc --grammar=PolyModelica script.mos
    ```

=== "OMEdit"

    **Tools → Options → General → Grammar** → select *PolyModelica*.

Without the flag, PolyModelica syntax is a plain parse error (for example,
`polyvector` declarations or the infix `is` operator will not parse).

## Your first model

Save this as `DeclBasic.mo`:

```modelica
--8<-- "DeclBasic.mo"
```

Then check it from a `.mos` script:

```modelica
setCommandLineOptions("--grammar=PolyModelica"); getErrorString();
loadFile("DeclBasic.mo"); getErrorString();
checkModel(DeclBasic); getErrorString();
```

```
"Check of DeclBasic completed successfully."
```

## Inspecting the lowering

The whole dialect is a parse-time rewrite into standard Modelica, and you can
always look at the result. From a script:

```modelica
list(DeclBasic); getErrorString();
```

The interesting part of the output — the polyvector became two plain arrays,
and the field slice became a `cat`:

```modelica
A base_v_a[3] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
B base_v_b[2] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
Real total;
equation
  total = sum(cat(1, base_v_a.x, base_v_b.x));
```

In OMEdit, right-click a class in the Libraries browser and choose
**View Lowered Modelica** to see the same thing.

!!! warning "OMEdit: text editing is safe, graphical editing rewrites your file"

    OMEdit regenerates a class's text from its internal (lowered)
    representation when you save after a **graphical** edit — drawing in the
    Icon/Diagram views or changing values through dialogs will overwrite your
    `.mo` file with the lowered code. Editing in the **text view** is safe.
    See [Errors and limitations](errors.md#omedit-and-graphical-editing).

## Simulating

Nothing special is needed: after lowering, the model is standard Modelica.

```modelica
setCommandLineOptions("--grammar=PolyModelica"); getErrorString();
loadFile("Economy.mo"); getErrorString();
simulate(Economy, stopTime = 10); getErrorString();
val(totalWealth, 10);
```

Continue with the [language guide](language/polyvector.md), or jump to the
[Economy walkthrough](examples.md).
