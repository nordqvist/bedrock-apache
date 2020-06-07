FROM wordpress:5-apache

# Based on squareweave/bedrocker (https://github.com/squareweave/bedrocker)

# Bedrock Version and SHA1 checksum
ENV BEDROCK_VERSION=1.13.5 \
    BEDROCK_SHA256=f731fbd764ea28c2c12a851f40d92a132de2f8f489e8f9015c220e2309ab4667

# WP-CLI Version and SHA1 checksum
ENV WP_CLI_VERSION=2.4.0 \
    WP_CLI_SHA256=139dcc86ed39ef751679efbdaf57a53528f1afda972c4e3622667cc27397b540

# Composer Version and SHA1 checksum
ENV COMPOSER_VERSION=1.10.7 \
    COMPOSER_SHA256=b94b872729668de5b5fbf62f16ff588d2a23480dda88c0e45cb43b721b75ae29

# Default environment variables
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    WP_ENV=development \
    DEFAULT_TIMEZONE=Sweden/Stockholm \
    WEBROOT=/app/web

# Install Bedrock dependencies
RUN set -xe && \
    apt-get -qq update && \
    apt-get -qq install \
        git \
        zlib1g-dev \
        libzip-dev \
        less \
        subversion \
        default-mysql-client \
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
    echo "$WP_CLI_SHA256 */usr/local/bin/wp" | sha256sum -c - && \
    chmod +x  /usr/local/bin/wp && \
    true

# Install Composer
RUN set -xe && \
    curl -sS -o /usr/local/bin/composer \
        -L https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar && \
    sha1sum /usr/local/bin/composer && \
    echo "$COMPOSER_SHA256 */usr/local/bin/composer" | sha256sum -c - && \
    chmod +x  /usr/local/bin/composer && \
    true

# Set directory for Bedrock
WORKDIR /app

RUN set -xe && \
    rm -rf /usr/src/wordpress && \
    true

# Install Bedrock
RUN set -xe && \
    curl -sS -o /tmp/bedrock.tar.gz \
        -L https://github.com/roots/bedrock/archive/${BEDROCK_VERSION}.tar.gz && \
    echo "$BEDROCK_SHA256 */tmp/bedrock.tar.gz" | sha256sum -c - && \
    tar --strip-components=1 -xzf /tmp/bedrock.tar.gz -C /app && \
    rm /tmp/bedrock.tar.gz && \
    chown -R www-data:www-data /app && \
    composer install --no-interaction --no-dev && \
    composer clear-cache && \
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
    echo "DocumentRoot /app/web" >> /etc/apache2/apache2.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's#<Directory /var/www/>.*#<Directory /app/web/>#' /etc/apache2/apache2.conf && \
    ln -s /etc/apache2/conf-available/wordpress-rewrite.conf /etc/apache2/conf-enabled/wordpress-rewrite.conf && \
    true

# Hook Bedrock wp-config
RUN set -xe && \
    { \
        echo "<?php"; \
        echo "require('/app/web/wp-config.php');"; \
        echo "require_once(ABSPATH . 'wp-settings.php');"; \
    } > /app/web/wp/wp-config.php && \
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
