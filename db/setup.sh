#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
HOME_DIR="$(cd "$(dirname $SCRIPT_DIR)" && pwd)"

IS_POSTGRES_RUNNING=false

source "$SCRIPT_DIR/sh_common.sh"

# START
[ $# -ne 0 ] && showError "$0 doesn't accept any parameter"

if [ ! -f "$HOME_DIR/.env" ]; then
   showError "Postgresql environment file $HOME_DIR/.env does not exist"
   exit 0
else
   source "$HOME_DIR/.env"
fi

if [ ! -f /usr/local/bin/pg_ctl ]; then
   showError "postgres is not installed"
   exit 0
fi

# check if postgres server is running
if [ ! -f /usr/local/var/postgres/postmaster.pid ]; then
    # start postgres server
    pg_ctl -D /usr/local/var/postgres start -s -l "postgres_`date +%Y%m%d_%H%M%S`.log"
else
   IS_POSTGRES_RUNNING=true
fi

dbname=$POSTGRES_DATABASE

if [ -z $dbname ]; then
   showError "Postgresqp database name undefined"
   exit 0
fi

# check if db exists
db_found=`psql -lt | grep $dbname | cut -f 1 -d \|`

if [ -z $db_found ]; then
    # create db if not found
    createdb $dbname
    psql -d $dbname -f $SCRIPT_DIR/createext.psql
else
    formatRed "Do you want to overwrite the existing database $dbname?"
    choice_no="No"
    choice_yes="Yes"
    choices=($choice_yes $choice_no)
    select target in $choices;
    do
        case $target in
            $choice_no|"")
                echo Goodbye!
                break;;
            *)
                echo "Dropping database $dbname..."
                dropdb $dbname
                echo "Creating database $dbname..."
                createdb $dbname
                psql -d $dbname -f $SCRIPT_DIR/createext.psql
                break;;
        esac
    done
fi

# stop postgres server
if expr $IS_POSTGRES_RUNNING = false > /dev/null; then
    pg_ctl -D /usr/local/var/postgres -s stop
fi
