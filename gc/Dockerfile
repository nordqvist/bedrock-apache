FROM wordpress:4-apache

# -----
# Based on greatbeyond/apache-php7
# -----

ENV PHP_CONF /usr/local/etc/php/conf.d

# update the repository
RUN apt-get update

# Install sendmail support
RUN apt-get install -y ssmtp && \
  echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf && \
  echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > ${PHP_CONF}/mail.ini

# Add gcfuse repo.
RUN apt-get install -y gnupg && \
  export GCSFUSE_REPO=gcsfuse-jessie && \
  echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install gcfuse.
RUN apt-get update && \
  apt-get install -y gcsfuse

# -----
# Based on nordqvist/bedrock-apache (https://github.com/nordqvist/bedrock-apache)
# -----

# Bedrock Version and SHA1 checksum
ENV BEDROCK_VERSION=1.8.5 \
  BEDROCK_SHA1=6f9b2b4b094b914e29000f00e71ed39782535206

# Composer Version and SHA1 checksum
ENV COMPOSER_VERSION=1.8.0 \
  COMPOSER_SHA1=7c60bb1635fdd16fb268a00fefa0bf97d6535e6a

# Default environment variables
ENV LC_ALL=C.UTF-8 \
  LANG=C.UTF-8 \
  DEFAULT_TIMEZONE=UTC+1 \
  WEBROOT=/app/web

# Install Bedrock dependencies
RUN set -xe && \
  apt-get -qq update && \
  apt-get -qq install \
  git \
  libzip-dev \
  less \
  --no-install-recommends \
  && \
  docker-php-ext-install zip && \
  apt-get clean && \
  rm -r /var/lib/apt/lists/* && \
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




# Get Bedrock
RUN set -xe && \
  curl -sS -o /tmp/bedrock.tar.gz \
  -L https://github.com/roots/bedrock/archive/${BEDROCK_VERSION}.tar.gz && \
  echo "$BEDROCK_SHA1 */tmp/bedrock.tar.gz" | sha1sum -c - && \
  tar --strip-components=1 -xzf /tmp/bedrock.tar.gz -C /app && \
  rm /tmp/bedrock.tar.gz && \
  true

# set folder permissions
RUN chown -R www-data:www-data /app /var/www

# Switch to non-root user
USER www-data

# Intall Bedrock
RUN set -xe && \
  composer install --no-interaction --no-dev && \
  composer remove \
  johnpbloch/wordpress \
  --no-interaction && \
  composer clear-cache && \
  true

# Switch back to root user
USER root

# Get latest version of WordPress from WordPress Docker image
RUN set -xe && \
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
