# Informacion sobre las rutas

Informacion sobre el contenido manejado sobre cada rutas de la api-sascha

# Tabla de contenido 
* [Host | Port](#host-port)
* [Test](#test)
* [Modelo Generico](#modelo-generico)
* [Maestros](#maestros)
    * [appmoviles](#appmoviles)
    * [bloquehorarios](#bloquehorarios)
    * [comidas](#comidas)
    * [condicionGarantias](#condiciongarantias)
    * [contenidos](#contenidos)
    * [diaLaborables](#dialaborables)
    * [ejercicios](#ejercicios)
    * [especialidades](#especialidades)
    * [estados](#estados)
    * [estadoCiviles](#estadociviles)
    * [generos](#generos)
    * [negocios](#negocios)
    * [rangoEdades](#rangoedades)
    * [redSociales](#redsociales)
    * [roles](#roles)
    * [slides](#slides)
    * [tiempos](#tiempos)
    * [tipocitas](#tipocitas)
    * [tipocomentarios](#tipocomentarios)
    * [tipocriterios](#tipocriterios)
    * [tipodietas](#tipodietas)
    * [tipoincidencias](#tipoincidencias)
    * [tipomotivos](#tipomotivos)
    * [tipoordenes](#tipoordenes)
    * [tipoparametros](#tipoparametros)
    * [tiporespuestas](#tiporespuestas)
    * [tipounidades](#tipounidades)
    * [tipovaloraciones](#tipovaloraciones)
    * [tiponotificaciones](#tiponotificaciones)
* [agendas](#agendas)
* [alimentos](#alimentos)
* [calificaciones](#calificaciones)
* [comentarios](#comentarios)
* [citas](#citas)
* [clientes](#clientes)
* [comentarios](#comentarios)
* [criterios](#criterios)
* [detallePlanDietas](#detalleplandietas)
* [detallePlanEjercicios](#detalleplanejercicios)
* [detallePlanSuplementos](#detalleplansuplementos)
* [detalleRegimenAlimentos](#detalleregimenalimentos)
* [detalleVisitas](#detallevisitas)
* [empleados](#empleados)
* [especialidadeEmpleados](#especialidadempleados)
* [especialidadeServicios](#especialidadservicios)
* [frecuencias](#frecuencias)
* [funcionalidades](#funcionalidades)
* [garantiaServicios](#garantiaservicios)
* [grupoalimenticios](#grupoalimenticios)
* [horarioEmpleados](#horarioempleados)
* [incidencias](#incidencias)
* [motivos](#motivos)
* [ordenServicios](#ordenservicios)
* [parametros](#parametros)
* [parametroClientes](#parametroclientes)
* [parametroPromociones](#parametropromociones)
* [parametroServicios](#parametroservicios)
* [plandietas](#plandietas)
* [planejercicios](#planejercicios)
* [plansuplementos](#plansuplementos)
* [precios](#precios)
* [preferenciaClientes](#preferenciaclientes)
* [promociones](#promociones)
* [reclamos](#reclamos)
* [regimenDietas](#regimendietas)
* [regimenEjercicios](#regimenejercicios)
* [regimenSuplementos](#regimensuplementos)
* [respuestas](#respuestas)
* [rolFuncionalidades](#rolfuncionalidades)
* [servicios](#servicios)
* [solicitudServicios](#solicitudservicios)
* [suplementos](#suplementos)
* [unidades](#unidades)
* [usuarios](#usuarios)
* [valoraciones](#valoraciones)
* [visitas](#visitas)

* [Usuarios](#usuarios)
* [Servicios](#servicios)
* [Promociones](#promociones)
* [Dietas](#dietas)
* [Tipo Dietas](#tipo-dietas)
* [Tipo Citas](#tipo-citas)
* [Tipo Criterios](#tipo-criterios)
* [Tipo Incidencias](#tipo-incidencias)
* [Tipo Motivos](#tipo-motivos)
* [Tipo Ordenes](#tipo-ordenes)
* [Tipo Parametros](#tipo-parametros)
* [Tipo Respuestas](#tipo-respuestas)
* [Tipo Unidades](#tipo-unidades)
* [Tipo Valoraciones](#tipo-valoraciones)
* [Negocio](#negocio)
* [Unidades](#unidades)
* [Suplementos](#suplementos)
* [Ejercicios](#ejercicios)

# Host | Port

Local con:
ir a [http://localhost:5000](http://localhost:5000) en tu nevegador

Heroku con:
ir a [https://api-sascha.heroku.com/](http://api-sascha.heroku.com/) en tu nevegador

# Test

Postman [https://www.getpostman.com/](https://www.getpostman.com/)

# Modelo Generico

```
    ├─GET────/objeto          * Retorna todos.
    ├─POST───/objeto          * Guarda. 
    ├─GET────/objeto/:id      * Retorna por id.
    ├─PUT────/objeto/:id      * Actualiza.
    ├─DELETE─/objeto/:id      * Elimina.


 ├─GET────/objetos
    ├─JSON 200
    ├──{
        "error": false,
        "data": [{
            "atributo":"valor"
        }]
    }
 ├─POST───/objetos
    ├─JSON 200
    ├──{
    "error": false,
    "data": [
        {
            "msg": "Registro Creado"
        }
    ]}
 ├─GET────/objetos/1
    ├─JSON 200
    ├──{
        
    }
    ├─JSON 400
        ├──´´[{
            "error": true,
        "data": [ msg:"" ]
    }]
├─PUT───/objeto/1
    ├─JSON 200
    ├──{
    "error": false,
    "data": [
        {
            "msg": "Registro actualizado"
        }
    ]}
├─PUT───/objeto/1
    ├─JSON 200
    ├──{
    "error": false,
    "data": [
        {
            "msg": "Registro eliminado"
        }
    ]}
```

# agendas

[[ver json]](https://api-sascha.herokuapp.com/agendas)

# alimentos

[[ver json]](https://api-sascha.herokuapp.com/alimentos)

# appmoviles

[[ver json]](https://api-sascha.herokuapp.com/appmoviles)

# bloquehorarios

[[ver json]](https://api-sascha.herokuapp.com/bloquehorarios)

# comidas

[[ver json]](https://api-sascha.herokuapp.com/comidas)


# condicionGarantias

[[ver json]](https://api-sascha.herokuapp.com/condiciongarantias)

# contenidos

[[ver json]](https://api-sascha.herokuapp.com/contenidos)

# diaLaborables

[[ver json]](https://api-sascha.herokuapp.com/dialaborables)

# ejercicios

[[ver json]](https://api-sascha.herokuapp.com/ejercicios)

# especialidades

[[ver json]](https://api-sascha.herokuapp.com/especialidades)

# estados

[[ver json]](https://api-sascha.herokuapp.com/estados)

# estadoCiviles

[[ver json]](https://api-sascha.herokuapp.com/estadociviles)

# generos

```
    ├─GET────/generos     * Retorna todos.
    ├─POST───/generos     * Guarda. 
    ├─GET────/genero/:id   * Retorna por id.
    ├─PUT────/genero/:id   * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/genero/:id   * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/generos)

# negocios

```
    ├─GET────/negocios       * Retorna todos.
    ├─POST───/negocios       * Guarda. 
    ├─GET────/negocio/:id    * Retorna por id.
    ├─PUT────/negocio/:id    * Actualiza.
    ├─Body─{
            "razon_social": req.body.razon_social, 
            "rif": "", 
            "url_logo": "", 
            "mision": "", 
            "vision": "", 
            "objetivo": "", 
            "telefono": "", 
            "correo": "", 
            "latitud": "", 
            "longitud": ""
        } 
    ├─DELETE─/genero/:id   * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/negocios)

# rangoEdades

[[ver json]](https://api-sascha.herokuapp.com/rangoedades)

# redSociales

```
    ├─GET────/redsociales       * Retorna todos.
    ├─POST───/redsociales       * Guarda. 
    ├─GET────/redsocial/:id     * Retorna por id.
    ├─PUT────/redsocial/:id     * Actualiza.
    ├─Body─{
            "nombre":"" ,
            "url_base":"" ,
            "url_logo":""
        } 
    ├─DELETE─/genero/:id   * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/redsociales)

# roles

[[ver json]](https://api-sascha.herokuapp.com/roles)

# slides

[[ver json]](https://api-sascha.herokuapp.com/slides)

# tiempos

[[ver json]](https://api-sascha.herokuapp.com/tiempos)

# tipocitas

```
    ├─GET────/tipocitas         * Retorna todos.
    ├─POST───/tipocitas         * Guarda. 
    ├─GET────/tipocita/:id      * Retorna por id.
    ├─PUT────/tipocita/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipocita/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipocitas)

# tipocomentarios

```
    ├─GET────/tipocomentarios         * Retorna todos.
    ├─POST───/tipocomentarios         * Guarda. 
    ├─GET────/tipocomentario/:id      * Retorna por id.
    ├─PUT────/tipocomentario/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipocomentarios/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipocomentarios)

# tipocriterios

```
    ├─GET────/tipocriterios         * Retorna todos.
    ├─POST───/tipocriterios         * Guarda. 
    ├─GET────/tipocriterio/:id      * Retorna por id.
    ├─PUT────/tipocriterio/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipocriterio/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipocriterios)

# tipodietas

```
    ├─GET────/tipodietas         * Retorna todos.
    ├─POST───/tipodietas         * Guarda. 
    ├─GET────/tipodieta/:id      * Retorna por id.
    ├─PUT────/tipodieta/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipodieta/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipodietas)

# tipoincidencias

```
    ├─GET────/tipoincidencias         * Retorna todos.
    ├─POST───/tipoincidencias         * Guarda. 
    ├─GET────/tipoincidencia/:id      * Retorna por id.
    ├─PUT────/tipoincidencia/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipoincidencia/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipoincidencias)

# tipomotivos

```
    ├─GET────/tipomotivos         * Retorna todos.
    ├─POST───/tipomotivos         * Guarda. 
    ├─GET────/tipomotivo/:id      * Retorna por id.
    ├─PUT────/tipomotivo/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipomotivo/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipomotivos)

# tipoordenes

```
    ├─GET────/tipoordenes         * Retorna todos.
    ├─POST───/tipoordenes         * Guarda. 
    ├─GET────/tipoordene/:id      * Retorna por id.
    ├─PUT────/tipoordene/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipoordene/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipoordenes)

# tipoparametros

```
    ├─GET────/tipoparametros         * Retorna todos.
    ├─POST───/tipoparametros         * Guarda. 
    ├─GET────/tipoparametro/:id      * Retorna por id.
    ├─PUT────/tipoparametro/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipoparametro/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipoparametros)

# tiporespuestas

```
    ├─GET────/tiporespuestas         * Retorna todos.
    ├─POST───/tiporespuestas         * Guarda. 
    ├─GET────/tiporespuesta/:id      * Retorna por id.
    ├─PUT────/tiporespuesta/:id      * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tiporespuesta/:id      * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tiporespuestas)

# tipounidades

```
    ├─GET────/tipounidades         * Retorna todos.
    ├─POST───/tipounidades         * Guarda. 
    ├─GET────/tipounidad/:id       * Retorna por id.
    ├─PUT────/tipounidad/:id       * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipounidad/:id       * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipounidades)

# tipovaloraciones

```
    ├─GET────/tipovaloraciones         * Retorna todos.
    ├─POST───/tipovaloraciones         * Guarda. 
    ├─GET────/tipovaloracion/:id       * Retorna por id.
    ├─PUT────/tipovaloracion/:id       * Actualiza.
    ├─Body─{
            "nombre": ""
        }  
    ├─DELETE─/tipovaloracion/:id       * Elimina.
```

[[ver json]](https://api-sascha.herokuapp.com/tipovaloraciones)

# calificaciones

[[ver json]](https://api-sascha.herokuapp.com/calificaciones)

# citas

[[ver json]](https://api-sascha.herokuapp.com/citas)

# clientes

[[ver json]](https://api-sascha.herokuapp.com/clientes)

# comentarios

[[ver json]](https://api-sascha.herokuapp.com/comentarios)

# criterios

[[ver json]](https://api-sascha.herokuapp.com/criterios)

# detallePlanDietas

[[ver json]](https://api-sascha.herokuapp.com/detalleplandietas)

# detallePlanEjercicios

[[ver json]](https://api-sascha.herokuapp.com/detalleplanejercicios)

# detallePlanSuplementos

[[ver json]](https://api-sascha.herokuapp.com/detalleplansuplementos)

# detalleRegimenAlimentos

[[ver json]](https://api-sascha.herokuapp.com/detalleregimenalimentos)

# detalleVisitas

[[ver json]](https://api-sascha.herokuapp.com/detallevisitas)

# empleados

[[ver json]](https://api-sascha.herokuapp.com/empleados)

# especialidadeEmpleados

[[ver json]](https://api-sascha.herokuapp.com/especialidadeempleados)

# especialidadeServicios

[[ver json]](https://api-sascha.herokuapp.com/especialidadeservicios)

# frecuencias

[[ver json]](https://api-sascha.herokuapp.com/frecuencias)

# funcionalidades

[[ver json]](https://api-sascha.herokuapp.com/funcionalidades)

# garantiaServicios

[[ver json]](https://api-sascha.herokuapp.com/garantiaservicios)

# grupoalimenticios

[[ver json]](https://api-sascha.herokuapp.com/grupoalimenticios)

# horarioEmpleados

[[ver json]](https://api-sascha.herokuapp.com/horarioempleados)

# incidencias

[[ver json]](https://api-sascha.herokuapp.com/incidencias)

# motivos

```
    ├─GET────/motivos          * Retorna todos.
    ├─POST───/motivos          * Guarda. 
    ├─GET────/motivos_tipo/:id * Retorna todos los motivos por tipo_motivo.
    ├─GET────/motivo/:id       * Retorna por id.
    ├─PUT────/motivo/:id       * Actualiza.
    ├─DELETE─/motivo/:id       * Eliminacion logica por id.
    ├─Body─{ 
        "id_tipo_motivo": 1, 
        "descripcion": "" 
    }
```

[[ver json]](https://api-sascha.herokuapp.com/motivos)

# ordenServicios

[[ver json]](https://api-sascha.herokuapp.com/ordenservicios)

# parametros

[[ver json]](https://api-sascha.herokuapp.com/parametros)

# parametroClientes

[[ver json]](https://api-sascha.herokuapp.com/parametroclientes)

# parametroPromociones

[[ver json]](https://api-sascha.herokuapp.com/parametropromociones)

# parametroServicios

[[ver json]](https://api-sascha.herokuapp.com/parametroservicios)

# plandietas

```
    ├─GET────/plandietas         * Retorna todos.
    ├─POST───/plandietas         * Guarda. 
    ├─GET────/plandieta/:id      * Retorna por id.
    ├─PUT────/plandieta/:id      * Actualiza.
    ├─DELETE─/plandieta/:id       * Elimina.
    ├─Body─{
        "id_tipo_dieta": 2,
        "nombre": "", 
        "descripcion": ""
    }
```

[[ver json]](https://api-sascha.herokuapp.com/plandietas)

# planejercicios

```
    ├─GET────/planejercicios         * Retorna todos.
    ├─POST───/planejercicios         * Guarda. 
    ├─GET────/planejercicio/:id      * Retorna por id.
    ├─PUT────/planejercicio/:id      * Actualiza.
    ├─DELETE─/planejercicio/:id       * Elimina.
    ├─Body─{
        "nombre": "", 
        "descripcion": ""
    }
```

[[ver json]](https://api-sascha.herokuapp.com/planejercicios)

# plansuplementos

[[ver json]](https://api-sascha.herokuapp.com/plansuplementos)

# precios

```
    ├─GET────/precios        * Retorna todos.
    ├─POST───/precios        * Guarda. 
    ├─GET────/precio/:id      * Retorna por id.
    ├─PUT────/precio/:id      * Actualiza.
    ├─DELETE─/precio/:id      * Elimina.
    ├─Body─{
        "id_unidad": 0,
        "nombre":"Dos millones quinientos",
        "valor": 2500000 
    }
```

[[ver json]](https://api-sascha.herokuapp.com/precios)

# preferenciaClientes

[[ver json]](https://api-sascha.herokuapp.com/preferenciaclientes)

# promociones

[[ver json]](https://api-sascha.herokuapp.com/promociones)

# reclamos

[[ver json]](https://api-sascha.herokuapp.com/reclamos)

# regimenDietas

[[ver json]](https://api-sascha.herokuapp.com/regimendietas)

# regimenEjercicios

[[ver json]](https://api-sascha.herokuapp.com/regimenejercicios)

# regimenSuplementos

[[ver json]](https://api-sascha.herokuapp.com/regimensuplementos)

# respuestas

[[ver json]](https://api-sascha.herokuapp.com/respuestas)

# rolFuncionalidades

[[ver json]](https://api-sascha.herokuapp.com/rolfuncionalidades)

# servicios

[[ver json]](https://api-sascha.herokuapp.com/servicios)

# solicitudServicios

[[ver json]](https://api-sascha.herokuapp.com/solicitudes)

# suplementos

```
    ├─GET────/suplementos         * Retorna todos.
    ├─POST───/suplementos         * Guarda. 
    ├─GET────/suplemento/:id      * Retorna por id.
    ├─PUT────/suplemento/:id      * Actualiza.
    ├─DELETE─/suplemento/:id       * Elimina.
    ├─Body─{
        "nombre": "",
        "descripcion": "",
        "id_unidad":19
    }
```

[[ver json]](https://api-sascha.herokuapp.com/suplementos)

# unidades

[[ver json]](https://api-sascha.herokuapp.com/unidades)

# usuarios       

[[ver json]](https://api-sascha.herokuapp.com/usuarios)

# valoraciones

[[ver json]](https://api-sascha.herokuapp.com/valoraciones)

# visitas

[[ver json]](https://api-sascha.herokuapp.com/visitas)


# Usuarios

```
 ├──/
 	├─GET────/usuarios 			* Retorna todos.
    ├─POST───/usuarios 			* Guarda.
    ├─GET────/usuario/:id 		* Retorna por id.
    ├─PUT────/usuario/:id 		* Actualiza.
    ├─DELETE─/usuario/:id 		* Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/usuarios)

# Servicios

```
    ├─GET────/servicios 		* Retorna todos.
    ├─POST───/servicios 		* Guarda. 
    ├─GET────/servicio/:id 		* Retorna por id.
    ├─PUT────/servicio/:id 		* Actualiza.
    ├─DELETE─/servicio/:id 		* Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/servicios)

# Promociones

```
    ├─GET────/promociones        * Retorna todos.
    ├─POST───/promociones        * Guarda. 
    ├─GET────/promocion/:id      * Retorna por id.
    ├─PUT────/promocion/:id      * Actualiza.
    ├─DELETE─/promocion/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/promociones)

# Dietas

```
    ├─GET────/dietas         * Retorna todos.
    ├─POST───/dietas         * Guarda. 
    ├─GET────/dieta/:id      * Retorna por id.
    ├─PUT────/dieta/:id      * Actualiza.
    ├─DELETE─/dieta/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/dietas)

# Tipo Dietas

```
    ├─GET────/tipodietas         * Retorna todos.
    ├─POST───/tipodietas         * Guarda. 
    ├─GET────/tipodieta/:id      * Retorna por id.
    ├─PUT────/tipodieta/:id      * Actualiza.
    ├─DELETE─/tipodieta/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipodietas)

# Tipo Citas

```
    ├─GET────/tipocitas         * Retorna todos.
    ├─POST───/tipocitas         * Guarda. 
    ├─GET────/tipocita/:id      * Retorna por id.
    ├─PUT────/tipocita/:id      * Actualiza.
    ├─DELETE─/tipocita/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipocitas)

# Tipo Criterios

```
    ├─GET────/tipocriterios         * Retorna todos.
    ├─POST───/tipocriterios         * Guarda. 
    ├─GET────/tipocriterio/:id      * Retorna por id.
    ├─PUT────/tipocriterio/:id      * Actualiza.
    ├─DELETE─/tipocriterio/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipocriterios)

# Tipo Incidencias

```
    ├─GET────/tipoincidencias         * Retorna todos.
    ├─POST───/tipoincidencias         * Guarda. 
    ├─GET────/tipoincidencia/:id      * Retorna por id.
    ├─PUT────/tipoincidencia/:id      * Actualiza.
    ├─DELETE─/tipoincidencia/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipoincidencias)

# Tipo Motivos

```
    ├─GET────/tipomotivos         * Retorna todos.
    ├─POST───/tipomotivos         * Guarda. 
    ├─GET────/tipomotivo/:id      * Retorna por id.
    ├─PUT────/tipomotivo/:id      * Actualiza.
    ├─DELETE─/tipomotivo/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipomotivos)

# Tipo Ordenes

```
    ├─GET────/tipoordenes         * Retorna todos.
    ├─POST───/tipoordenes         * Guarda. 
    ├─GET────/tipoorden/:id       * Retorna por id.
    ├─PUT────/tipoorden/:id       * Actualiza.
    ├─DELETE─/tipoorden/:id       * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipoordenes)

# Tipo Parametros

```
    ├─GET────/tipoparametros       * Retorna todos.
    ├─POST───/tipoparametros       * Guarda. 
    ├─GET────/tipoparametro/:id    * Retorna por id.
    ├─PUT────/tipoparametro/:id    * Actualiza.
    ├─DELETE─/tipoparametro/:id    * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipoparametros)

# Tipo Respuestas

```
    ├─GET────/tiporespuestas       * Retorna todos.
    ├─POST───/tiporespuestas       * Guarda. 
    ├─GET────/tiporespuesta/:id    * Retorna por id.
    ├─PUT────/tiporespuesta/:id    * Actualiza.
    ├─DELETE─/tiporespuesta/:id    * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tiporespuestas)

# Tipo Unidades

```
    ├─GET────/tipounidades        * Retorna todos.
    ├─POST───/tipounidades        * Guarda. 
    ├─GET────/tipounidad/:id      * Retorna por id.
    ├─PUT────/tipounidad/:id      * Actualiza.
    ├─DELETE─/tipounidad/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipounidades)

# Tipo Valoraciones

```
    ├─GET────/tipovaloraciones     * Retorna todos.
    ├─POST───/tipovaloraciones     * Guarda. 
    ├─GET────/tipovaloracion/:id   * Retorna por id.
    ├─PUT────/tipovaloracion/:id   * Actualiza.
    ├─DELETE─/tipovaloracion/:id   * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/tipovaloraciones)

# Tipo Notificaciones

```
    ├─GET────/tiponotificaciones       * Retorna todos.
    ├─PUT────/tiponotificaciones/:id   * Actualiza.
```
[[ver json]](https://api-sascha.herokuapp.com/tiponotificaciones)


# Unidades

```
    ├─GET────/unidades        * Retorna todos.
    ├─POST───/unidades        * Guarda. 
    ├─GET────/unidad/:id      * Retorna por id.
    ├─PUT────/unidad/:id      * Actualiza.
    ├─DELETE─/unidad/:id      * Elimina.
    ├─Body─{
        "id_tipo_unidad":0,
        "nombre": "",
        "abreviatura":"",
        "simbolo": ""
    }
```
[[ver json]](https://api-sascha.herokuapp.com/unidades)

# Suplementos

```
    ├─GET────/suplementos         * Retorna todos.
    ├─POST───/suplementos         * Guarda. 
    ├─GET────/suplemento/:id      * Retorna por id.
    ├─PUT────/suplemento/:id      * Actualiza.
    ├─DELETE─/suplemento/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/suplementos)

# Ejercicio

```
    ├─GET────/ejercicios         * Retorna todos.
    ├─POST───/ejercicios         * Guarda. 
    ├─GET────/ejercicio/:id      * Retorna por id.
    ├─PUT────/ejercicio/:id      * Actualiza.
    ├─DELETE─/ejercicio/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/ejercicios)

# Negocio

```
    ├─GET────/negocios         * Retorna todos.
    ├─POST───/negocios         * Guarda. 
    ├─GET────/negocio/:id      * Retorna por id.
    ├─PUT────/negocio/:id      * Actualiza.
    ├─DELETE─/negocio/:id      * Elimina.
```
[[ver json]](https://api-sascha.herokuapp.com/negocios)
