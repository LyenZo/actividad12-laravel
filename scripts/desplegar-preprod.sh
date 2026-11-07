#!/usr/bin/env bash
# Despliega un artefacto en el servidor de preproduccion (ejecutar en el servidor).
set -euo pipefail

ARTEFACTO="${1:?Uso: desplegar-preprod.sh <archivo.tar.gz> <version>}"
VERSION="${2:?Falta la version}"
BASE="/var/www/laravel-preprod"
RELEASE="${BASE}/releases/${VERSION}"

sudo mkdir -p "${BASE}/releases" "${BASE}/shared/storage"
sudo mkdir -p "$RELEASE"
sudo tar -xzf "$ARTEFACTO" -C "$RELEASE"

# Variables de entorno y storage compartidos entre versiones
if [ ! -f "${BASE}/shared/.env" ]; then
  sudo cp "${RELEASE}/.env.example" "${BASE}/shared/.env"
  echo "AVISO: edite ${BASE}/shared/.env con los valores de preproduccion y ejecute php artisan key:generate"
fi
if [ -z "$(ls -A "${BASE}/shared/storage" 2>/dev/null)" ]; then
  sudo cp -a "${RELEASE}/storage/." "${BASE}/shared/storage/"
fi
sudo rm -rf "${RELEASE}/storage"
sudo ln -sfn "${BASE}/shared/storage" "${RELEASE}/storage"
sudo ln -sfn "${BASE}/shared/.env" "${RELEASE}/.env"

# Permisos
sudo chown -R www-data:www-data "${BASE}/shared/storage" "${RELEASE}/bootstrap/cache"
sudo chmod -R ug+rwx "${BASE}/shared/storage" "${RELEASE}/bootstrap/cache"

# Preparar la aplicacion
cd "$RELEASE"
sudo -u www-data php artisan migrate --force
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache

# Activar la version y recargar servicios
sudo ln -sfn "$RELEASE" "${BASE}/current"
sudo systemctl reload php8.3-fpm
sudo systemctl reload nginx
echo "Version ${VERSION} desplegada en preproduccion"
