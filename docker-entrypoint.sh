#!/bin/bash
# Bash script identifier

set -e
# Exit on fail

# rm -f /app/tmp/pids/${RAILS_ENV:-development}.pid

bundle check || bundle install

exec "$@"
# Finally call command issued to the docker service
