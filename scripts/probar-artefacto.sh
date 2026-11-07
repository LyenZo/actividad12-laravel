#!/usr/bin/env bash
# Instala el artefacto en un directorio limpio y ejecuta una prueba de humo.
set -euo pipefail

CARPETA="${1:?Uso: probar-artefacto.sh <carpeta_con_artefacto> <version>}"
VERSION="${2:?Falta la version}"
DESTINO="$(mktemp -d)"

echo "== Verificando suma SHA-256 =="
(cd "$CARPETA" && sha256sum -c SHA256SUMS)

echo "== Verificando contenido =="
bash "$(dirname "$0")/verificar-artefacto.sh" "${CARPETA}/laravel-release-${VERSION}.tar.gz"

echo "== Extrayendo en ${DESTINO} =="
tar -xzf "${CARPETA}/laravel-release-${VERSION}.tar.gz" -C "$DESTINO"
cd "$DESTINO"

echo "== Preparando entorno de pruebas =="
cp .env.example .env
sed -i 's/^APP_ENV=.*/APP_ENV=staging/; s/^APP_DEBUG=.*/APP_DEBUG=false/' .env
sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
sed -i '/^DB_HOST=/d; /^DB_PORT=/d; /^DB_DATABASE=/d; /^DB_USERNAME=/d; /^DB_PASSWORD=/d' .env
touch database/database.sqlite
php artisan key:generate --force
php artisan migrate --force
chmod -R ug+rwx storage bootstrap/cache

echo "== Optimizando para produccion =="
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "== Prueba de humo =="
php -S 127.0.0.1:8000 -t public >/tmp/servidor.log 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null || true' EXIT
sleep 3
RESPUESTA="$(curl -fsS http://127.0.0.1:8000/version)"
echo "$RESPUESTA"
echo "$RESPUESTA" | grep -q "\"version\":\"${VERSION}\""
echo "Artefacto instalado y funcionando: ${VERSION}"
