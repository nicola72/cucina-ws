# ---------- Build stage (composer) ----------
FROM composer:2 AS vendor

WORKDIR /app
COPY . .

# Install PHP deps (no dev) and optimize autoloader
RUN composer install \
  --no-dev \
  --prefer-dist \
  --no-interaction \
  --no-progress \
  --optimize-autoloader


# ---------- Runtime stage ----------
FROM php:8.2-fpm-alpine

# System deps
RUN apk add --no-cache \
    nginx \
    supervisor \
    bash \
    icu-dev \
    oniguruma-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    postgresql-dev \
  && docker-php-ext-install \
    pdo \
    pdo_pgsql \
    intl \
    mbstring \
    zip \
    opcache

# Configure working directory
WORKDIR /var/www/html

# Copy app + vendor from build stage
COPY --from=vendor /app /var/www/html

# Nginx + Supervisor configs
COPY docker/nginx.conf.template /etc/nginx/nginx.conf.template
COPY docker/supervisord.conf /etc/supervisord.conf

# Entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ensure writable dirs
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
 && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

ENV APP_ENV=production
ENV APP_DEBUG=false

# Render sets $PORT; we'll bind nginx to it via envsubst in entrypoint
EXPOSE 10000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
