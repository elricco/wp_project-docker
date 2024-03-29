#!/bin/bash
_os="`uname`"
_now=$(date +"%Y-%m-%d_%H-%M_%S")
_file="wp-data/data_$_now.sql"

# Export dump
EXPORT_COMMAND='exec mysqldump "$MYSQL_DATABASE" -uroot -p"$MYSQL_ROOT_PASSWORD"'
docker-compose exec mysql sh -c "$EXPORT_COMMAND" > $_file

if [[ $_os == "Darwin"* ]] ; then
  sed -i '.bak' 1,1d $_file
else
  sed -i 1,1d $_file # Removes the password warning from the file
fi

gzip -c $_file > wp-data/wp-latest.sql.gz