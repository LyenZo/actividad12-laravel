#!/usr/bin/env bash
# Verifica que el artefacto contenga lo necesario y no incluya informacion sensible.
set -euo pipefail

ARTEFACTO="${1:?Uso: verificar-artefacto.sh <archivo.tar.gz>}"
LISTA="$(mktemp)"
tar -tzf "$ARTEFACTO" > "$LISTA"
ERRORES=0

echo "== Archivos obligatorios =="
for RUTA in artisan composer.json composer.lock VERSION vendor/autoload.php public/index.php public/build/manifest.json bootstrap/app.php .env.example; do
  if grep -qx "./${RUTA}" "$LISTA"; then
    echo "OK    ${RUTA}"
  else
    echo "FALTA ${RUTA}"; ERRORES=$((ERRORES+1))
  fi
done

echo "== Archivos que NO deben existir =="
if grep -E '(^|/)\.env(\..+)?$' "$LISTA" | grep -v '\.env\.example$'; then
  echo "ERROR: el artefacto incluye archivos .env"; ERRORES=$((ERRORES+1))
else
  echo "OK    sin archivos .env"
fi
for PATRON in '^\./\.git/' '^\./node_modules/' '^\./tests/' '\.pem$' '\.key$' 'id_rsa' 'id_ed25519'; do
  if grep -E "$PATRON" "$LISTA" >/dev/null; then
    echo "ERROR: se encontro contenido prohibido (${PATRON})"; ERRORES=$((ERRORES+1))
  fi
done

echo "== Dependencias de desarrollo =="
if grep -q '^\./vendor/phpunit/' "$LISTA"; then
  echo "ERROR: vendor incluye PHPUnit (dependencias de desarrollo)"; ERRORES=$((ERRORES+1))
else
  echo "OK    sin dependencias de desarrollo"
fi

rm -f "$LISTA"
if [ "$ERRORES" -gt 0 ]; then
  echo "Verificacion fallida con ${ERRORES} error(es)"; exit 1
fi
echo "Verificacion correcta"
