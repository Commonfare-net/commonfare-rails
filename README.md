# Commonfare.net

## Setup the development environment with Docker

### docker-sync

**VERY IMPORTANT FOR macOS** to have reasonable speeds when accessing assets in development.

1. Install the gems

```
gem install docker-sync docker-compose
```

2. Install OS specific devDependencies: https://github.com/EugenMayer/docker-sync/wiki/1.-Installation#os-specific

  or just if you use MacOS

  ```bash
  $ brew install unison
  $ brew install eugenmayer/dockersync/unox
  ```

3. Build the images following the instructions below

### Building images

Build the images and run the containers:

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

#### Setup the environment

Copy `app_variables.env.example` to `app_variables.env` and change the variables to your values.

### Start and stop containers

#### Using docker-sync (recommended on macOS)

```sh
docker-sync-stack start
# CTRL+C to stop
```

This will take a long time the first time you start.

See https://github.com/EugenMayer/docker-sync/wiki/2.2-sync-stack-commands

#### Using docker-compose

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

Every time you modify the `Gemfile` you have to reinstall the gems and update the Gemfile.lock, then **rebuild** the docker image of the Rails app, so:

```bash
$ docker-compose run --rm app bundle install
$ docker-compose build
$ docker-compose up -d
```

*This will re-create the image so the `bundle` will take quite some time.*

This will recreate only the Rails container from the new image, and not the DB container, that this way persists data.

## Migrations

Use `docker-compose exec` to generate migrations while working with `docker-sync`.

```bash
$ docker-compose exec app rails generate migration YourMigration
```

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
