FROM wordpress:4-apache

# Based on squareweave/bedrocker (https://github.com/squareweave/bedrocker)

# Bedrock Version and SHA1 checksum
ENV BEDROCK_VERSION=1.8.5 \
  BEDROCK_SHA1=6f9b2b4b094b914e29000f00e71ed39782535206

# WP-CLI Version and SHA1 checksum
ENV WP_CLI_VERSION=1.4.1 \
  WP_CLI_SHA1=e7a9be3c2b82e953843c993ccc6b76952ed4f1bd

# Composer Version and SHA1 checksum
ENV COMPOSER_VERSION=1.8.0 \
  COMPOSER_SHA1=7c60bb1635fdd16fb268a00fefa0bf97d6535e6a

# Default environment variables
ENV LC_ALL=C.UTF-8 \
  LANG=C.UTF-8 \
  DEFAULT_TIMEZONE=Sweden/Stockholm \
  WEBROOT=/app/web

# Install Bedrock dependencies
RUN set -xe && \
  apt-get -qq update && \
  apt-get -qq install \
  git \
  zlib1g-dev \
  less \
  mysql-client \
  --no-install-recommends \
  && \
  docker-php-ext-install zip && \
  apt-get clean && \
  rm -r /var/lib/apt/lists/* && \
  true

# Install WP-CLI
RUN set -xe && \
  curl -sS -o /usr/local/bin/wp \
  -L https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar && \
  sha1sum /usr/local/bin/wp && \
  echo "$WP_CLI_SHA1 */usr/local/bin/wp" | sha1sum -c - && \
  chmod +x  /usr/local/bin/wp && \
  true

# Install Composer
RUN set -xe && \
  curl -sS -o /usr/local/bin/composer \
  -L https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar && \
  sha1sum /usr/local/bin/composer && \
  echo "$COMPOSER_SHA1 */usr/local/bin/composer" | sha1sum -c - && \
  chmod +x  /usr/local/bin/composer && \
  true

# Set directory for Bedrock
WORKDIR /app

# Install Bedrock
RUN set -xe && \
  curl -sS -o /tmp/bedrock.tar.gz \
  -L https://github.com/roots/bedrock/archive/${BEDROCK_VERSION}.tar.gz && \
  echo "$BEDROCK_SHA1 */tmp/bedrock.tar.gz" | sha1sum -c - && \
  tar --strip-components=1 -xzf /tmp/bedrock.tar.gz -C /app && \
  rm /tmp/bedrock.tar.gz && \
  chown -R www-data:www-data /app && \
  composer remove \
  johnpbloch/wordpress \
  --no-interaction && \
  composer install --no-interaction --no-dev && \
  true

# Get latest version of WordPress from WordPress Docker image
RUN set -xe && \
  composer install --no-interaction --no-dev && \
  composer clear-cache && \
  rm -rf /app/web/wp && \
  ln -s /usr/src/wordpress /app/web/wp && \
  true

# Add WordPress rewrite to config
ADD wordpress-rewrite.conf /etc/apache2/conf-available/wordpress-rewrite.conf

# Configure PHP
RUN set -xe && \
  { \
  echo 'date.timezone = ${DEFAULT_TIMEZONE}'; \
  } > /usr/local/etc/php/conf.d/date-timezone.ini && \
  { \
  echo 'upload_max_filesize=50M'; \
  echo 'post_max_size=60M'; \
  } > /usr/local/etc/php/conf.d/upload-limit.ini && \
  { \
  echo 'display_errors=0'; \
  } > /usr/local/etc/php/conf.d/error-reporting.ini && \
  true

# Configure Apache
RUN set -xe && \
  echo "DocumentRoot /app/web\nServerSignature Off\nServerTokens Prod" >> /etc/apache2/apache2.conf && \
  rm /etc/apache2/sites-enabled/000-default.conf && \
  sed -i 's#<Directory /var/www/>.*#<Directory /app/web/>#' /etc/apache2/apache2.conf && \
  sed -i 's#Options Indexes FollowSymLinks.*#Options FollowSymLinks#' /etc/apache2/apache2.conf && \
  ln -s /etc/apache2/conf-available/wordpress-rewrite.conf /etc/apache2/conf-enabled/wordpress-rewrite.conf && \
  true

# Hook Bedrock wp-config
RUN set -xe && \
  { \
  echo "<?php"; \
  echo "define('FORCE_SSL_ADMIN', true);"; \
  echo "if ( strpos(\$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false ) \$_SERVER['HTTPS'] = 'on';"; \
  echo "require('/app/web/wp-config.php');"; \
  echo "require_once(ABSPATH . 'wp-settings.php');"; \
  } > /usr/src/wordpress/wp-config.php && \
  true

# Bind uploads folder
RUN set -xe && \
  mkdir -p /app/web/app/uploads && \
  true

VOLUME /app/web/app/uploads

# Add our entrypoint and make it executable
ADD run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]

# CMD ["apache2-foreground"]
