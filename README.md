# bedrock-apache

Docker Image for Production and Development deployment of [Bedrock](https://roots.io/bedrock/)

## Getting started

You should have a .env.production and .env.local for production and development variables. You might for example let the installation handle the environment variables for the database connection and in that case exclude them from the .env.production file.

Your Dockerfile should include the following:

```dockerfile
FROM nordqvist/bedrock-apache:production

ADD .env.production /app/.env
```
for production

```dockerfile
FROM nordqvist/bedrock-apache:dev

ADD .env.local /app/.env
```
for development

If changes has been to the config files to accomodate for custom environment variables make sure to add them to the container like this:

```dockerfile
ADD /config /app/config/
```

Add the project files
```dockerfile
ADD web/app/ app/web/app/
```

or bind them to your local folder if used for development
```dockerfile
VOLUME web/app/ app/web/app/
```

Add the project composer file.
```dockerfile
ADD composer.json composer.lock /app/
```

If you want to take advantage of upstream WordPress updates run this command.
```
RUN composer remove johnpbloch/wordpress --no-interaction
```

And finally install the composer dependecies
```dockerfile
RUN composer install && composer clear-cache
```

You should also bind `/app/web/app/uploads` to your persistent storage.

### Example: Production Dockerfile

```dockerfile
FROM nordqvist/bedrock-apache:production

ADD .env.production /app/.env
ADD /config /app/config/

ADD web/app/ app/web/app/

ADD composer.json composer.lock /app/

RUN composer remove johnpbloch/wordpress --no-interaction
RUN composer install && composer clear-cache
```

### Example: Development Dockerfile

```dockerfile
FROM nordqvist/bedrock-apache:dev

ADD .env.local /app/.env
ADD /config /app/config/

VOLUME web/app/ app/web/app/

ADD composer.json composer.lock /app/

RUN composer remove johnpbloch/wordpress --no-interaction
RUN composer install && composer clear-cache
```

If you are using Docker compose for your development your docker-compose.yml-file should look something like this:

```yaml
version: '3.2'
services:
  db:
    image: 'mysql:5.7'
    volumes:
      - db_data:/var/lib/mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: docker_db
      MYSQL_USER: docker_db_user
      MYSQL_PASSWORD: docker_db_password
    ports:
      - "4306:3306"
  bedrock:
    depends_on:
      - db
    build:
        context: .
        dockerfile: Dockerfile.local
    volumes:
      - type: bind
        source: ./web/app/uploads
        target: /app/web/app/uploads
      - type: bind
        source: ./web/app
        target: /app/web/app
    ports:
      - '8000:80'
    restart: always
    environment:
      DB_HOST: 'db:3306'
      DB_NAME: docker_db
      DB_USER: docker_db_user
      DB_PASSWORD: docker_db_password`
volumes:
    db_data:
```