# Documentacion de las rutas

Informacion sobre el contenido manejado sobre cada rutas de la api-sascha

# Tabla de contenido 
* [Host | Port](#host-port)
* [Rutas | Json](#rutas-json)
    * [Usuarios](#usuarios)
    * [Servicios](#servicios)

# Host | Port

Local con http://localhost:5000/
Heroku con http://api-sascha.heroku.com/

# Rutas | Json

## Usuarios

 ├──/[Host | Port](#host-port)
 	├─GET────/usuarios 			* Retorna todos.
    ├─POST───/usuarios 			* Guarda.
    ├─GET────/usuario/:id 		* Retorna.
    ├─PUT────/usuario/:id 		* Actualiza.
    ├─DELETE─/usuario/:id 		* Elimina.
    ├─POST───/login	 			* Inicia de session.


 ├─GET────/usuarios
	├─JSON 200
	├──[{
    	"error": false,
    	"data": []
	}];
 	├─JSON 400
    ├──[{
    	"error": true,
    	"data": [ msg:"" ]
	}]│


## Servicios

 ├──/[Host | Port](#host-port) 
 	├─GET────/servicios 		* Retorna todos.
    ├─POST───/servicios 		* Guarda. 
    ├─GET────/servicio/:id 		* Retorna.
    ├─PUT────/servicio/:id 		* Actualiza.
    ├─DELETE─/servicio/:id 		* Elimina.


 ├─GET────/servicios
	├─JSON 200
	├──[{
    	"error": false,
    	"data": {
        "id_servicio": 1,
        "estatus": 1,
        "id_plan_dieta": 1,
        "id_plan_ejercicio": 1,
        "id_plan_suplemento": 1,
        "nombre": "",
        "descripcion": "",
        "url_imagen": "",
        "precio": 0,
        "numero_visita": 0,
        "fecha_creacion": "",
        "fecha_actualizacion": ""
	}];
 ├─GET────/servicios/1
	├─JSON 200
	├──[{
    	"error": false,
    	"data": {
        "id_servicio": 1,
        "estatus": 1,
        "id_plan_dieta": 1,
        "id_plan_ejercicio": 1,
        "id_plan_suplemento": 1,
        "nombre": "",
        "descripcion": "",
        "url_imagen": "",
        "precio": 0,
        "numero_visita": 0,
        "fecha_creacion": "",
        "fecha_actualizacion": ""
	}];
 	├─JSON 400
    │	├──[{
    │		"error": true,
    │		"data": [ msg:"" ]
	│	}]│

