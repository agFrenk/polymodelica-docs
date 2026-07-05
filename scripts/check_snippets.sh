#!/usr/bin/env bash
# Valida todos los snippets de la doc contra el omc real (fork PolyModelica).
#
#   snippets/*.mo         deben cargar y pasar checkModel sin errores.
#   snippets/errors/*.mo  deben FALLAR, y el error debe contener la cadena
#                         declarada en la primera línea del archivo:
#                         // expect-error: <substring>
#
# Uso: scripts/check_snippets.sh [archivo.mo ...]   (sin args: todos)
set -u
OMC=/home/agus-modelica/Documents/facu/openmodelica-poly/install_cmake/bin/omc
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

check_ok() {
  local file=$1 cls mos out
  cls=$(basename "${file%.mo}")
  mos=$(mktemp --suffix=.mos)
  printf 'setCommandLineOptions("--grammar=PolyModelica");getErrorString();loadFile("%s");getErrorString();checkModel(%s);getErrorString();\n' \
    "$file" "$cls" > "$mos"
  out=$("$OMC" "$mos" 2>&1)
  rm -f "$mos"
  if grep -q "Error" <<<"$out"; then
    echo "FAIL  $file"
    sed 's/^/      /' <<<"$out"
    return 1
  fi
  echo "ok    $file"
}

check_error() {
  local file=$1 cls mos out expected
  expected=$(head -1 "$file" | sed -n 's|^// expect-error: ||p')
  if [ -z "$expected" ]; then
    echo "FAIL  $file (falta la línea '// expect-error: ...')"
    return 1
  fi
  cls=$(basename "${file%.mo}")
  mos=$(mktemp --suffix=.mos)
  printf 'setCommandLineOptions("--grammar=PolyModelica");getErrorString();loadFile("%s");getErrorString();checkModel(%s);getErrorString();\n' \
    "$file" "$cls" > "$mos"
  out=$("$OMC" "$mos" 2>&1)
  rm -f "$mos"
  if grep -qF "$expected" <<<"$out"; then
    echo "ok    $file (error esperado presente)"
  else
    echo "FAIL  $file (no apareció: $expected)"
    sed 's/^/      /' <<<"$out"
    return 1
  fi
}

if [ $# -gt 0 ]; then
  files=("$@")
else
  mapfile -t files < <(find "$ROOT/snippets" -name '*.mo' | sort)
fi

for f in "${files[@]}"; do
  case "$f" in
    */errors/*) check_error "$f" || fail=1 ;;
    *)          check_ok "$f"    || fail=1 ;;
  esac
done

exit $fail
