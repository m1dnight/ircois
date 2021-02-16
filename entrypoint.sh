#!/bin/bash
# docker entrypoint script.

# wait until Postgres is ready
while ! pg_isready -q -h $DATABASE_HOST -p 5432 -U $DATABASE_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

bin="/app/bin/ircois"

# Setup the database.
eval "$bin eval \"Ircois.Release.migrate\""

# start the elixir application
exec "$bin" "start" 