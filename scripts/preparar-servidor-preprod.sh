#!/usr/bin/env bash
# Prepara un servidor Ubuntu Server 24.04 para recibir artefactos de Laravel.
set -euo pipefail

sudo apt update
sudo apt install -y nginx mysql-server unzip curl \
  php8.3-fpm php8.3-cli php8.3-mysql php8.3-mbstring php8.3-xml \
  php8.3-curl php8.3-zip php8.3-bcmath php8.3-intl

sudo mkdir -p /var/www/laravel-preprod/releases /var/www/laravel-preprod/shared
sudo chown -R www-data:www-data /var/www/laravel-preprod

sudo mysql -e "CREATE DATABASE IF NOT EXISTS laravel_preprod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'laravel_preprod'@'localhost' IDENTIFIED BY 'CAMBIAR_CONTRASENA';"
sudo mysql -e "GRANT ALL PRIVILEGES ON laravel_preprod.* TO 'laravel_preprod'@'localhost'; FLUSH PRIVILEGES;"
echo "Servidor preparado. Configure Nginx con docs/nginx-preprod.conf"
