# Commonfare.net

## Setup the develompent environment with Docker

Build the image for the Rails app container:

```bash
$ docker build -t commonfare .
```

Build the images for Composer and run the containers:

```bash
$ docker-compose build
$ docker-compose up
```

Edit `database.yml`:

```yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  timeout: 5000
  username: postgres
  host: postgres
  port: 5432

development:
  <<: *default
  database: commonfare_development

test:
  <<: *default
  database: commonfare_test

production:
  <<: *default
  database: commonfare_production
```

Create the database and run migrations

```bash
$ docker-compose run app rake db:create
$ docker-compose run app rake db:migrate
```

### Start and stop containers

Don't use **up** and **down** just to restart the rails server, because this will cause the container to be destroyed and recreated, and the data in the DB will be lost.

Instead, use **start** and **stop** like this:

```bash
$ docker-compose start
$ docker-compose stop
```

## `Gemfile` modifications

Every time you modify the `Gemfile` you have to **rebuild** the docker image of the Rails app, so:

```bash
$ docker build .
```

*This will re-create the image so the `bundle` will take quite some time.*

Then you have to rebuild also with Composer an then use **up**:

```bash
$ docker-compose build
$ docker-compose up
```

This will recreate only the Rails container from the new image, and not the DB container, that this way persists data.

## Debug with `pry`

Find out the Container ID and attach to the container logs

```bash
$ docker ps
$ docker attach ID
```

When done, exit `pry` by entering `exit` and detach from the container with `Ctrl+P` `Ctrl+Q`. Don't use `Ctrl+C` because you wuld kill the rails server and so the container itself.
