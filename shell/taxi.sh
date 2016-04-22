#!/bin/bash

TAXIUSR="Answrs"
TAXIPWD="answrs1"

echo "Which enviroment do you want call TAXI agent ?"
echo "[1] Development enviroment ?"
echo "[2] Test environment ?"
read env

if [ "$env" = "1" ]
then
        if [ -z $1 ] 
        then 
              echo "please feed me with the right ANSWRS Message taht you want to load"
              exit
        fi
        TAXI_URL="http://answrs-dev.wwctrials.com:80/~ros/taxi/index.php"
else
        if [ -z $1 ] 
        then 
              echo "please feed me with the right ANSWRS Message taht you want to load"
              exit
        fi
        TAXI_URL="http://esb01-test.wwctrials.com:80/taxi/taxi/index.php"
fi
for i in {1..200}
do
	RES=`curl --user $TAXIUSR:$TAXIPWD -d"@$1" $TAXI_URL`
done
echo "done"
