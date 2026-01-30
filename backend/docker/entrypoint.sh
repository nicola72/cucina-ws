#!/usr/bin/env bash
set -e

# Render provides PORT; default for local use
export PORT="${PORT:-10000}"

# Render nginx.conf from template with PORT
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Laravel optimizations (safe in production)
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Run migrations at container start (recommended vs build-time)
php artisan migrate --force || true

exec "$@"
