#!/bin/bash

CONTAINER_NAME="hospital-sql"
MYSQL_ROOT_PASSWORD="my-secret-pw"
MYSQL_DATABASE="mydb"
MYSQL_USER="myuser"
MYSQL_PASSWORD="mypassword"
CONFIG_PATH=".my.cnf"

cat << EOF | sudo tee -a ${CONFIG_PATH}
[client]
user=root
password=my-secret-pw
host=localhost
EOF

docker run -d \
           --name $CONTAINER_NAME \
           -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
           -e MYSQL_DATABASE=$MYSQL_DATABASE \
           -e MYSQL_USER=$MYSQL_USER \
           -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
           -p 3306:3306 -d mysql:latest

docker cp ${CONFIG_PATH} ${CONTAINER_NAME}:/root/${CONFIG_PATH}
