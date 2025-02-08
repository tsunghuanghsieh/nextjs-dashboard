#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
HOME_DIR="$(cd "$(dirname $SCRIPT_DIR)" && pwd)"

IS_POSTGRES_RUNNING=false

source "$SCRIPT_DIR/sh_common.sh"

if [ ! -f "$HOME_DIR/.env" ]; then
   showError "Postgresql environment file $HOME_DIR/.env does not exist"
   exit 0
else
   source "$HOME_DIR/.env"
fi

# check if postgres server is running
if [ ! -f /usr/local/var/postgres/postmaster.pid ]; then
    # start postgres server
    pg_ctl -D /usr/local/var/postgres start -s -l "postgres_`date +%Y%m%d_%H%M%S`.log"
else
   IS_POSTGRES_RUNNING=true
fi

if [ -z $POSTGRES_DATABASE ]; then
    showError "Postgresqp database name undefined"
    exit 0
fi

echo Dropping database $POSTGRES_DATABASE...
dropdb $POSTGRES_DATABASE

# stop postgres server if we start it
if expr $IS_POSTGRES_RUNNING = false > /dev/null; then
    pg_ctl -D /usr/local/var/postgres -s stop
fi
