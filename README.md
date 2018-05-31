# api-sascha
API: Sascha

#Interfaz de programacion de aplicaciones

#Documentacion de las rutas

[[Rutas api-sascha]](https://github.com/SaschaNutric/api-sascha/tree/master/src/routes)

### Quick de inicio
**Hacer que tu version Node v8.9.4 and NPM = 5.6.0
> Clonar/Descargar el repositorio

```bash
# clona nuestro repositorio sascha

# moverse al directorio
cd ~/api-sascha

# intalar las dependencia node con
npm install

# iniciar el server
npm run start

```
ir a [http://localhost:5000](http://localhost:5000) en tu nevegador

>Resolver error: Cannot find module /bcrypt/lib/binding/bcrypt_lib.node' 

```bash
# Moverse en el directorio del proyecto 
# Ejecutar
npm install node-gyp -g
npm install bcrypt -g

npm install bcrypt -save
```

# Tabla de contenido
* [Archivo Estructura](#archivo-estructura)
* [Aranque Inicial](#aranque-inicial)
    * [Dependencias](#dependencias)
    * [Instalacion](#instalacion)
    * [Ejecutar la App](#ejecutando-la-app)
* [Usar Editores](#usar-editores)
* [Soporte, pregunta, o Feedback](#soporte-pregunta-o-feedback)
* [Despliegue](#despliegue)
* [License](#license)


## Archivo Estructura
Nosotro establesemos un orden de los archivo para mantener un estandar en el desarrollo de la intefaz de programacion de aplicaciones:
```
api-sascha/
 ├──db/					* Nuestro directorio server
 |   ├──saschadb.sql		* Script respaldo de la base de dato
 │
 ├──/node_modules			* Nuestro directorio de dependencias node
 │       
 ├──/public 				* Nuestro directorio publico
 │   ├──/menu.html 				* 
 │       
 ├──/src 					* Nuestro directorio src
 │   ├──/collections 			* Directorio de Colecciones Bookshelf
 │   │	 ├──objetos.js				* Coleccion de objetos
 │	 │ 	 
 │   ├──/commons				* Directorio de Config ORM Bookshelf
 │   │	 ├──bookshelf.js			* Congigura el bookshelf + knex y basedato
 │	 │ 	 
 │   ├──/controllers			* Directorio de los controladores de la api
 │   │	 ├──objetos.js				* Controlador de objetos
 │	 │ 	 
 │   ├──/middlewares			* Directorio intermediario
 │   │	 ├──auth.js				* Archivo para la autenticacion
 │	 │ 	 
 │   ├──/models 				* Directorio de Modelos
 │   │	 ├──objetos.js				* Modelo objetos
 │	 │ 	 
 │   ├──/routes					* Directorio de Rutas
 │   │	 ├──README.md				* Informacion sobre las rutas
 │	 │	 ├──index.js				* Indice de rutas de acceso a la api 
 │	 │ 	  
 │   ├──/services				* Directorio de los Servicio
 │   │	 ├──index.js				* Servicio indice 
 │      
 ├──.gitignore                  * Contenedor de los archivo ignorado por git
 ├──CONTRIBUTING.md             * Contenedor de las condiciones para los contribuidores
 ├──CONTRIBUTORS.md             * Contenedor de los contribuidores al projecto
 ├──LICENSE                     * GNU GENERAL PUBLIC LICENSE
 ├──README.md                   * Este Archivo
 ├──app.js                      * Principal configuracion de la aplicacion
 ├──config.js                   * configuracion de la api
 ├──knexfile.js                 * Datos para la coneccion con la base de dato
 ├──package-lock.json           * Registro de dependencia cargada en node_modules
 └──package.json                * Gestor npm 

```

# Aranque Inicial
## Dependencias
Que necesita para ejecutar esta app:

* `node` y `npm` 

ya instalado esto, tendras que instalar de forma globals con `npm install --global`:
* `express` (`npm install --global express`)

## Instalacion
* `fork` este repositorio.
* `clone` tu fork.
* `cd ~/api-sascha` mover al directorio.
* `npm install` para instalar dependencia node
* `npm run start` para iniciar el server

## Ejecutar la Aplicacion
Antes tienes que instalar toda las dependencia tu ahora puedes ejecutar la aplicacion. Ejecutar`npm run start`. El host y puerto por defecto es `http://localhost:5000` .

## Otro Comandos

### build files
```bash
# desarrollo
npm run dev
```
# Usar Editores
Nosotro tenemos experiencia usando editores:

* [Visual Studio Code](https://code.visualstudio.com/)
* [Webstorm](https://www.jetbrains.com/webstorm/download/)
* [Sublime Text](http://www.sublimetext.com/3) with [Typescript-Sublime-Plugin](https://github.com/Microsoft/Typescript-Sublime-plugin#installation)

# Support, Questions, or Feedback
> Contactanos y siguenos para saber sobre este repositorio

* [Chat: si-equipo3.slack](http://si-equipo3.slack.com/)
* [Twitter: @saschanutric](https://twitter.com/sachanutric)
* [Correo: sachanutric@gmail.com](https://google.com/)
* [Gitter: SaschaNutric/api-sascha](https://gitter.im/SaschaNutric/api-sascha)

# Despliegue

## Heroku

Para realizar el despliegue a heroku tu necesitas en tu **sistema operativo** instalado **git** (para clonar este repositorio) y [heroku](https://api-sascha.herokuapp.com/).

### Install heroku

#### Ubuntu:

```
sudo apt-get install heroku
cd ~/api-sascha
heroku login
heroku create
git push heroku master
heroku ps:scale web=1
heroku open

```
___

# License
 [MIT](/LICENSE)