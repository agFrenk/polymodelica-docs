#!/usr/bin/env bash
# polylist.sh Archivo.mo [Clase] — carga el archivo con --grammar=PolyModelica
# y muestra el código loweado (list) de la clase. Fuente: PLAN.md.
set -u
OMC=/home/agus-modelica/Documents/facu/openmodelica-poly/install_cmake/bin/omc
file=$1
cls=${2:-$(basename "${file%.mo}")}
mos=$(mktemp --suffix=.mos)
printf 'setCommandLineOptions("--grammar=PolyModelica");getErrorString();loadFile("%s");getErrorString();list(%s);getErrorString();\n' \
  "$file" "$cls" > "$mos"
"$OMC" "$mos"
rm -f "$mos"
