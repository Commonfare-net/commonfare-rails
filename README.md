# Commonfare.net

## Setup the development environment with Docker

Build the image for the Rails app container:

```bash
$ docker build -t commonfare .
```

Build the images for Composer and run the containers:

```bash
$ docker-compose build
$ docker-compose up -d
```

Create the database and run migrations

```bash
$ docker-compose run --rm app rake db:create
$ docker-compose run --rm app rake db:migrate
```

We use `yarn` for managing npm packages, so install it on your machine and run

```bash
$ yarn install
```

### Start and stop containers

Use **up** and **down** just to start up/shut down the rails server.

```bash
$ docker-compose up -d
$ docker-compose down
```

Alternatively, you can use **start**, **stop**, **restart** like this:

```bash
$ docker-compose start
$ docker-compose stop
$ docker-compose restart
```

## `Gemfile` modifications

Every time you modify the `Gemfile` you have to **rebuild** the docker image of the Rails app, so:

```bash
$ docker-compose build
$ docker-compose up -d
```

*This will re-create the image so the `bundle` will take quite some time.*

This will recreate only the Rails container from the new image, and not the DB container, that this way persists data.

## Debug with `pry`

From [this gist](https://gist.github.com/briankung/ebfb567d149209d2d308576a6a34e5d8).

Find out the Container ID and attach to the container logs

```bash
$ docker ps
$ docker attach ID
```

When done, exit `pry` by entering `exit` and detach from the container with `Ctrl+P` `Ctrl+Q`. Don't use `Ctrl+C` because you wuld kill the rails server and so the container itself.

## Translation

We use [translation.io](https://github.com/aurels/translation-gem), so  write text using `_('Free text')` and execute this command to push new keys and get new translations (You will need an APY key for this).

```bash
$ docker-compose run --rm app rake translation:sync
```

## Deployment

See the [wiki](https://github.com/PIENews/commonfare-rails/wiki)
