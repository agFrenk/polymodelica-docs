# Primeros pasos

PolyModelica vive en un fork de OpenModelica. Tanto el compilador de línea de
comandos (`omc`) como el editor gráfico (OMEdit) soportan el dialecto una vez
que habilitás la gramática PolyModelica.

## Habilitar el dialecto

El dialecto está apagado por defecto. El compilador se comporta como un
OpenModelica común hasta que seleccionás la gramática PolyModelica:

=== "Scripts omc (.mos)"

    ```modelica
    setCommandLineOptions("--grammar=PolyModelica");
    ```

=== "Línea de comandos omc"

    ```bash
    omc --grammar=PolyModelica script.mos
    ```

=== "OMEdit"

    **Tools → Options → General → Grammar** → seleccioná *PolyModelica*.

Sin el flag, la sintaxis PolyModelica es un error de parseo común y corriente
(por ejemplo, las declaraciones `polyvector` o el operador infijo `is` no
parsean).

## Tu primer modelo

Guardá esto como `DeclBasic.mo`:

```modelica
--8<-- "DeclBasic.mo"
```

Y chequealo desde un script `.mos`:

```modelica
setCommandLineOptions("--grammar=PolyModelica"); getErrorString();
loadFile("DeclBasic.mo"); getErrorString();
checkModel(DeclBasic); getErrorString();
```

```
"Check of DeclBasic completed successfully."
```

## Inspeccionar el lowering

Todo el dialecto es una reescritura en tiempo de parseo hacia Modelica
estándar, y siempre podés mirar el resultado. Desde un script:

```modelica
list(DeclBasic); getErrorString();
```

La parte interesante de la salida — el polyvector se convirtió en dos arrays
comunes, y el field slice en un `cat`:

```modelica
A base_v_a[3] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
B base_v_b[2] annotation(
  __PolyModelica(polyvector = "v", baseType = "Base"));
Real total;
equation
  total = sum(cat(1, base_v_a.x, base_v_b.x));
```

En OMEdit, hacé click derecho sobre una clase en el navegador de Libraries y
elegí **View Lowered Modelica** para ver lo mismo.

!!! warning "OMEdit: editar texto es seguro, editar gráficamente reescribe tu archivo"

    OMEdit regenera el texto de una clase desde su representación interna
    (loweada) cuando guarda después de una edición **gráfica** — dibujar en
    las vistas Icon/Diagram o cambiar valores por diálogos sobreescribe tu
    `.mo` con el código loweado. Editar en la **vista de texto** es seguro.
    Mirá [Errores y limitaciones](errors.md#omedit-y-la-edicion-grafica).

## Simular

No hace falta nada especial: después del lowering, el modelo es Modelica
estándar.

```modelica
setCommandLineOptions("--grammar=PolyModelica"); getErrorString();
loadFile("Economy.mo"); getErrorString();
simulate(Economy, stopTime = 10); getErrorString();
val(totalWealth, 10);
```

Seguí con la [guía del lenguaje](language/polyvector.md), o saltá al
[walkthrough de Economy](examples.md).
