#!/bin/bash

# Define variables
CONTAINER_NAME="hospital-sql"
SQL_SCRIPT_PATH=$1
DB_USER="myuser"
DB_PASSWORD="mypassword"
DB_NAME="mydb"

# Execute the SQL script inside the container
docker exec -i $CONTAINER_NAME mysql --defaults-file=/root/.my.cnf $DB_NAME < $SQL_SCRIPT_PATH | column -t
