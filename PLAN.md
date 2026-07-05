# Plan: sitio de documentación de PolyModelica

Documentación **para desarrolladores que usan el dialecto** (no internals del
compilador), como sitio web estático. Decisiones ya tomadas con Agustín:

- **Framework**: MkDocs Material.
- **Bilingüe**: inglés (default) + español, con selector de idioma en el header
  → plugin `mkdocs-static-i18n` (estructura por sufijo: `page.md` + `page.es.md`).
- **Alcance**: guía de usuario del dialecto. NO documentar la arquitectura
  interna del compilador.
- **Repo**: este directorio es un repo git propio (ya inicializado, rama `main`),
  separado del fork de OpenModelica.
- Dependencias SOLO en un venv local `.venv/` (nunca `pip --user` ni tocar el
  Python del sistema; si falta un paquete de sistema, pedirle a Agustín que lo
  instale él con `! sudo apt ...`).

## Contexto: qué es PolyModelica

Dialecto de Modelica con **arrays polimórficos**, desarrollado por Agustín
Frenkel (tesis, futura PR upstream a OpenModelica). Implementado como fork de
OpenModelica. La idea central: un `polyvector` declara un array cuyo tipo base
es una clase parcial y cuyos elementos son instancias de subtipos concretos:

```modelica
polyvector Base[3] v = {A[1], B[2]};   // 1 elemento A + 2 elementos B
```

Sobre eso el dialecto ofrece: field slices (`v.x`), iteración (`for s in v loop`),
predicados de tipo (`s is A`, `isSubtype`), `match`/`case`/`otherwise` por tipo,
comprehensions e indexación (`v[i]`, `w[s]`).

**Cómo funciona (contrato clave, ya verificado):** el lowering a Modelica
vainilla ocurre EN EL PARSEO — `PolyModelicaElaboration.elaborate()` es llamada
desde `Parser.mo` justo después del parse, solo con `--grammar=PolyModelica`.
La symbol table de OMC guarda el programa ya loweado, por lo que
`list(Clase)` / `listFile(Clase)` devuelven Modelica puro 100% estándar:
polyvector → arrays vainilla con annotation `__PolyModelica(polyvector="...",
baseType="...")`, slices → `cat(1, ...)`, for sobre polyvector → loops
desenrollados por sub-array, match → if-expressions / ecuaciones if.
El front-end nuevo (NFInst) solo agrega un chequeo de subtipo nominal que
emite el error `POLYVECTOR_INCOMPATIBLE_TYPE`.

## Fuentes de verdad (rutas absolutas)

- Fork: `/home/agus-modelica/Documents/facu/openmodelica-poly`, rama
  `demo/omedit-presentation` (compilada e instalada).
- omc funcionando: `/home/agus-modelica/Documents/facu/openmodelica-poly/install_cmake/bin/omc`
- OMEdit funcionando: `/home/agus-modelica/Documents/facu/openmodelica-poly/install_cmake/bin/OMEdit`
  (tiene selector de gramática en Tools → Options → General → Grammar, y una
  acción de click derecho "View Lowered Modelica" que muestra el código loweado).
- **Tests = la spec ejecutable**:
  `/home/agus-modelica/Documents/facu/openmodelica-poly/testsuite/openmodelica/polymodelica/`
  (~169 archivos .mo/.mos). Familias: Cardinality, Comprehension, Declaration,
  FieldSlice, Index, Is, Match, NestedFor, NumericFor, PolyFor, Predicate,
  PredicateGrowth, SliceAccumulation, SliceOps, SlicingInBinding, SubPoly.
  Los `.mos` con `list(M)` muestran el antes/después del lowering; los que
  esperan `Error` documentan las restricciones del dialecto.
- Contrato del lowering: header (~primeras 80 líneas) de
  `/home/agus-modelica/Documents/facu/openmodelica-poly/OMCompiler/Compiler/FrontEnd/PolyModelicaElaboration.mo`
- Ejemplo grande ya validado end-to-end (compila, simula, valores chequeados):
  `/home/agus-modelica/Documents/facu/demo-polymodelica/Economy.mo` (+
  `demo_check.mos`, `COMANDOS.md` con comandos útiles).

## Setup (primer paso en la sesión nueva)

```bash
python3 -m venv .venv
.venv/bin/pip install mkdocs-material mkdocs-static-i18n
.venv/bin/mkdocs serve   # preview en http://127.0.0.1:8000
```

`.gitignore` ya incluye `.venv/` y `site/`.

## Estructura propuesta del sitio

```
mkdocs.yml
docs/
  index.md / index.es.md                    # qué es PolyModelica, ejemplo antes/después
  getting-started.md / .es.md               # omc --grammar=PolyModelica, OMEdit (selector + View Lowered Modelica)
  language/
    polyvector.md / .es.md                  # declaración, sub-arrays, modificaciones
    access.md / .es.md                      # indexación v[i]/w[s], field slices v.x, slicing v[1:3]
    iteration.md / .es.md                   # for s in v, for numérico, anidado
    type-dispatch.md / .es.md               # is / isSubtype, match/case/otherwise
    comprehensions.md / .es.md
  lowering.md / .es.md                      # qué genera cada construcción (antes/después)
  errors.md / .es.md                        # POLYVECTOR_INCOMPATIBLE_TYPE, restricciones, limitación OMEdit
  examples.md / .es.md                      # walkthrough de Economy con simulación
```

Ajustar la estructura si el relevamiento de los tests revela otra agrupación
más natural — el TODO de análisis manda sobre este esqueleto.

## Flujo de trabajo del contenido

1. **TODO análisis (primero)**: catalogar la superficie sintáctica real desde
   los tests (leer varios .mo por familia, incluidos los de número alto que
   son edge cases, y los // Result: de los .mos, en especial los que esperan
   errores). NO documentar de memoria. Un subagente Explore sobre el
   directorio de tests funciona bien para esto.
2. Escribir las páginas en inglés.
3. **Validar CADA snippet de código de la doc contra el omc real** antes de
   publicarlo. Helper:

   ```bash
   polylist() {  # uso: polylist Archivo.mo [Clase]
     local mos; mos=$(mktemp --suffix=.mos)
     printf 'setCommandLineOptions("--grammar=PolyModelica");getErrorString();loadFile("%s");getErrorString();list(%s);getErrorString();\n' \
       "$1" "${2:-$(basename "${1%.mo}")}" > "$mos"
     /home/agus-modelica/Documents/facu/openmodelica-poly/install_cmake/bin/omc "$mos"; rm -f "$mos"
   }
   ```
4. Traducir a español (`.es.md`).
5. `mkdocs build --strict` sin warnings; commitear.

## Datos verificados reutilizables (sesión 2026-07-05)

- `Economy.mo` simula ok: `totalWealth(10) = 32.78`, `taxRevenue(10) = 7.13`
  (con `der(wealth)=0.6` para Worker da otros valores; el archivo actual usa 0.6).
- Lowering de Economy (salida real de `list()`): polyvector →
  `Worker agent_agents_worker[3]` + `Firm agent_agents_firm[2]` con annotations
  `__PolyModelica`; `sum(agents.wealth)` → `sum(cat(1, agent_agents_worker.wealth,
  agent_agents_firm.wealth))`; for+match → dos loops planos (`for a in 1:3` /
  `for a in 1:2`) con las constantes de cada caso.
- **Limitación a documentar en errors.md**: en OMEdit, guardar después de una
  edición GRÁFICA (dibujar en Icon/Diagram, diálogos) reescribe el .mo con el
  código loweado (OMEdit regenera el texto vía `listFile()`). La edición en la
  vista de TEXTO es segura. Verificado empíricamente.

## Convenciones

- Identificadores y código de ejemplo: en inglés.
- Español informal-neutro para las páginas `.es.md` (vos → evitar; usar tono
  neutro tipo "podés"/"declarás" está ok, es para la tesis de Agustín).
- Commits: convencionales (`docs: ...`), sin Co-Authored-By.

## Deploy (después, opcional)

Para la presentación alcanza `mkdocs serve` local. Si se quiere publicar:
crear repo en GitHub (p.ej. `agFrenk/polymodelica-docs`) y `mkdocs gh-deploy`,
o GitHub Pages con Actions. Decidirlo con Agustín.
