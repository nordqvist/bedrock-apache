FROM wordpress:4-apache

# Based on squareweave/bedrocker (https://github.com/squareweave/bedrocker)

# Package Versions and SHA1 Checksums
ENV BEDROCK_VERSION=1.8.5 \
    BEDROCK_SHA1=6f9b2b4b094b914e29000f00e71ed39782535206 \
    WP_CLI_VERSION=1.4.1 \
    WP_CLI_SHA1=e7a9be3c2b82e953843c993ccc6b76952ed4f1bd \
    COMPOSER_VERSION=1.5.6 \
    COMPOSER_SHA1=c09effd1675ae61a550de9f61f8293f792f9c336

# Default environment variables
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    WP_ENV=development \
    DEFAULT_TIMEZONE=Sweden/Stockholm \
    WEBROOT=/app/web

# Required dependencies
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

WORKDIR /app

# Install Bedrock
RUN set -xe && \
    curl -sS -o /tmp/bedrock.tar.gz \
        -L https://github.com/roots/bedrock/archive/${BEDROCK_VERSION}.tar.gz && \
    echo "$BEDROCK_SHA1 */tmp/bedrock.tar.gz" | sha1sum -c - && \
    tar --strip-components=1 -xzf /tmp/bedrock.tar.gz -C /app && \
    rm /tmp/bedrock.tar.gz && \
    chown -R www-data:www-data /app && \
    composer install --no-interaction --no-dev && \
    composer remove \
             johnpbloch/wordpress \
             --no-interaction && \
    composer install --no-interaction --no-dev && \
    composer clear-cache && \
    rm -rf /app/web/wp && \
    ln -s /usr/src/wordpress /app/web/wp && \
    true

COPY wordpress-rewrite.conf /etc/apache2/conf-available/wordpress-rewrite.conf

RUN set -xe && \
    { \
        echo 'date.timezone = ${DEFAULT_TIMEZONE}'; \
    } > /usr/local/etc/php/conf.d/date-timezone.ini && \
    { \
        echo 'upload_max_filesize=20M'; \
        echo 'post_max_size=60M'; \
    } > /usr/local/etc/php/conf.d/upload-limit.ini && \
    echo "DocumentRoot /app/web" >> /etc/apache2/apache2.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's#<Directory /var/www/>.*#<Directory /app/web/>#' /etc/apache2/apache2.conf && \
    ln -s /etc/apache2/conf-available/wordpress-rewrite.conf /etc/apache2/conf-enabled/wordpress-rewrite.conf && \
    { \
        echo "<?php"; \
        echo "require('/app/web/wp-config.php');"; \
        echo "require_once(ABSPATH . 'wp-settings.php');"; \
    } > /usr/src/wordpress/wp-config.php && \
    { \
        echo ""; \
        echo "if (file_exists(__DIR__ . '/application.local.php')) {"; \
        echo "    require(__DIR__ . '/application.local.php');"; \
        echo "}"; \
    } >> /app/config/application.php && \
    mkdir -p /app/web/app/uploads && \
    true

VOLUME /app/web/app/uploads

ENTRYPOINT []
CMD ["apache2-foreground"]