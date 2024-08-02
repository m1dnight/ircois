#!/bin/bash
bin="/app/bin/ircois"

eval "$bin eval \"Ircois.Release.migrate\""

# start the elixir application
exec "$bin" "start" 