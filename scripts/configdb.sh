#!/bin/bash

MODE='NULL'
DATABASE='saschadb'

if [ "$MODE" = "NULL" ]; then
	AUTO_CONFIG=$(psql postgres -c "\l $DATABASE" 2>/dev/null | grep "$DATABASE" | head -1 | cut -d" " -f2)
	if [ "$AUTO_CONFIG" = "$DATABASE" ]; then
		MODE='development'	
	else
		MODE='production'
	fi	
fi

if [ "$MODE" = "development" ]; then
	USER_DB='postgres'
	HOST='localhost'
	PORT='5432'
	PASSWORD='1234'

	credenciales="module.exports = {
    	client: \"pg\",
		connection: {
			host: \"$HOST\",
			user: \"$USER_DB\",
			password: \"$PASSWORD\",
			database: \"$DATABASE\"
		}
	}"

	echo "Configuracion modo desarrollo";
	res=$(psql postgres -c "\l $DATABASE" 2>/dev/null | grep "$DATABASE" | head -1 | cut -d" " -f2)
	if ! [ "$res" = "$DATABASE" ]; then
		echo "Creando la base de dato $DATABASE";
		psql -U $USER -h $HOST -p $PORT -c "CREATE DATABASE $DATABASE;"
	fi
	echo "Registrando credenciales_local para la base de dato";
	echo "module.exports = "$credenciales>knexfile.js
else
	if [ "$MODE" = "production" ]; then
		DATABASE='postgres://byqkxhkjgnspco:7f90354e72f531d4d0deb47be4fdfb68765244e8a5d97ca9c9f7f97c05a0a9a9@ec2-54-243-210-70.compute-1.amazonaws.com:5432/d7h3pnfqclegkn'
		USER_DB='byqkxhkjgnspco'
		HOST='ec2-54-243-210-70.compute-1.amazonaws.com'
		PORT='5432'
		PASSWORD='7f90354e72f531d4d0deb47be4fdfb68765244e8a5d97ca9c9f7f97c05a0a9a9'

		credenciales="module.exports = {
   			client: \"pg\",
			connection: {
				host: \"$HOST\",
				user: \"$USER_DB\",
				password: \"$PASSWORD\",
				database: \"$DATABASE\"
			}
		}"
		
		echo "Configuracion modo produccion";
		echo "Registrando credenciales_heroku para la base de dato";
		echo "module.exports = "$credenciales>knexfile.js
	fi
fi
echo