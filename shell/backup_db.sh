#!/bin/bash
DB=""
SCHEMA=""
DIR=/home/$LOGNAME/

function runcommand(){

   RES=$CMD

}

if [`uname`='Linux']
then 
   PS=/usr/lib/postgresql/9.0/bin
else
   PS=/usr/postgres/9.0-pgdg/bin/64/psql 
fi

if [ ! -z $1 ] || [ ! -z $2 ]
then
  DB=$1;
else
  echo "please provide the DB Name to Backup";
  echo "backup_db [dbname] [schema]";
  exit;
fi

SCHEMA=$2
CMD=`$PS/pg_dump  -Uwctdba -p5433 $DB --schema=$SCHEMA > $DIR/backup_db.$DB$-SCHEMA.bck`
runcommand
