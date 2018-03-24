#!/bin/bash

DATABASE='d7h3pnfqclegkn'
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
echo "$credenciales">knexfile.js
echo