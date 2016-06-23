#! /bin/bash

ps -ef | grep -e "[n]ode ./bin/www {{PRJ_NAME}}" | awk '{print $2}' | xargs kill
sleep 3

POSTFIX=`date '+%Y%m%d%H%M%S'`
mv nohup.out nohup.out.$POSTFIX

npm i
nohup npm start &
