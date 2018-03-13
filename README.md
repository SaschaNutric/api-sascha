# api-sascha
API: Sascha

#Interfaz de programacion de aplicaciones

### Quick de inicio
**Hacer que tu version Node v8.9.4 and NPM = 5.6.0
> Clonar/Descargar el repositorio

```bash
# clona nuestro repositorio sascha
sudo curl -sL https://raw.githubusercontent.com/SaschaNutric/scripts-bash/master/dist/run-sascha -o /bin/sascha 
sudo chmod a+x /bin/sascha 
sudo sascha init

# moverse al directorio
cd $HOME/git/sascha/api-sascha

# intalar las dependencia node con
npm install

# iniciar el server
npm start

```
ir a [http://localhost:3000](http://localhost:3000) en tu nevegador

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
 ├──bin/                        * Nuestro directorio server
 |   ├──www                 		* www configuracion para el server
 │
 ├──/node_modules               * Nuestro directorio de dependencias node
 │       
 ├──/public                     * Nuestro directorio publico
 │   ├──/images                    * Nuestro directorio statico de imagenes
 │   ├──/javascripts               * Nuestro directorio statico de javascripts
 │   ├──/stylesheets               * Nuestro directorio statico de estilos
 │       ├──stile.css            	* un simple stile.css
 │       
 ├──/routes                     * Nuestro directorio de rutas
 │   ├──index.js                    * indice de enrutamiento /index
 │   
 ├──/views                      * Nuestro directorio de vistas
 │   ├──index.js                    * vista indice /index
 │
 ├──.gitignore                  * Contenedor de los archivo ignorado por git
 ├──CONTRIBUTING.md             * Contenedor de las condiciones para los contribuidores
 ├──CONTRIBUTORS.md             * Contenedor de los contribuidores al projecto
 ├──LICENSE                     * GNU GENERAL PUBLIC LICENSE
 ├──README.md                   * Este Archivo
 ├──app.js                      * Principal configuracion de la aplicacion
 ├──gulpfile.js                 * Gestor gulp para sincronizacion, construccion, etc.
 ├──package-lock.json           * Registro de dependencia cargada en node_modules
 └──package.json                * Gestor npm 

```

# Aranque Inicial
## Dependencias
Que necesita para ejecutar esta app:
* `node` y `npm` (`sudo curl -sL https://raw.githubusercontent.com/SaschaNutric/scripts-bash/master/dist/run-tooldev -o /bin/tooldev && sudo chmod a+x /bin/tooldev && tooldev install node`)

ya instalado esto, tendras que instalar de forma globals con `npm install --global`:
* `express` (`npm install --global express`)

## Instalacion
* `fork` este repositorio
* `clone` tu fork
* `sudo curl -sL https://raw.githubusercontent.com/SaschaNutric/scripts-bash/master/dist/run-sascha -o /bin/sascha` 
* `sudo chmod a+x /bin/sascha`
* `sudo sascha init` para iniciar por medio del script sascha

* `npm install` para instalar dependencia node
* `npm run start` para iniciar el server

## Ejecutar la Aplicacion
Antes tienes que instalar toda las dependencia tu ahora puedes ejecutar la aplicacion. Ejecutar`npm run start`. El host y puerto por defecto es `http://localhost:3000` .

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

Para realizar el despliegue a heroku tu necesitas en tu **sistema operativo** instalado **git** (para clonar este repositorio) y [heroku](https://www.heroku.com/).

### Install heroku

#### Ubuntu:

```
sudo apt-get install heroku
cd $HOME/git/sascha/api-sascha
heroku login
heroku create
git push heroku master
heroku ps:scale web=1
heroku open

```
___

# License
 [MIT](/LICENSE)