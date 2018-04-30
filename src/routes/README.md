# Informacion sobre las rutas

Informacion sobre el contenido manejado sobre cada rutas de la api-sascha

# Tabla de contenido 
* [Host | Port](#host-port)
* [Test](#test)
* [Modelo Generico](#modelo-generico)
* [agendas](#agendas');
* [alimentos](#alimentos');
* [appmoviles](#app_moviles');
* [bloquehorarios](#bloque_horarios');
* [calificaciones](#calificaciones');
* [citas](#citas');
* [clientes](#clientes');
* [comentarios](#comentarios');
* [comidas](#comidas');
* [condicionGarantias](#condicion_garantias');
* [contenidos](#contenidos');
* [criterios](#criterios');
* [detallePlanDietas](#detalle_plan_dietas');
* [detallePlanEjercicios](#detalle_plan_ejercicios');
* [detallePlanSuplementos](#detalle_plan_suplementos');
* [detalleRegimenAlimentos](#detalle_regimen_alimentos');
* [detalleVisitas](#detalle_visitas')
* [diaLaborables](#dia_laborables')
* [ejercicios](#ejercicios')
* [empleados](#empleados')
* [especialidades](#especialidades')
* [especialidadeEmpleados](#especialidad_empleados')
* [especialidadeServicios](#especialidad_servicios')
* [estados](#estados')
* [estadoCiviles](#estado_civiles')
* [frecuencias](#frecuencias')
* [funcionalidades](#funcionalidades')
* [garantiaServicios](#garantia_servicios')
* [generos](#generos')
* [grupoalimenticios](#grupo_alimenticios')
* [horarioEmpleados](#horario_empleados')
* [incidencias](#incidencias')
* [motivos](#motivos')
* [negocios](#negocios')
* [ordenServicios](#orden_servicios')
* [parametros](#parametros')
* [parametroClientes](#parametro_clientes')
* [parametroPromociones](#parametro_promociones')
* [parametroServicios](#parametro_servicios')
* [plan_dietas](#plan_dietas')
* [plan_ejercicios](#plan_ejercicios')
* [plan_suplementos](#plan_suplementos')
* [precios](#precios')
* [preferenciaClientes](#preferencia_clientes')
* [promociones](#promociones')
* [rangoEdades](#rango_edades')
* [reclamos](#reclamos')
* [redSociales](#red_sociales')
* [regimenDietas](#regimen_dietas')
* [regimenEjercicios](#regimen_ejercicios')
* [regimenSuplementos](#regimen_suplementos')
* [respuestas](#respuestas')
* [roles](#roles')
* [rolFuncionalidades](#rol_funcionalidades')
* [servicios](#servicios')
* [slides](#slides')
* [solicitudServicios](#solicitud_servicios')
* [suplementos](#suplementos')
* [tiempos](#tiempos')
* [tipo_citas](#tipo_citas')
* [tipo_criterios](#tipo_criterios')
* [tipo_dietas](#tipo_dietas')
* [tipo_incidencias](#tipo_incidencias')
* [tipo_motivos](#tipo_motivos')
* [tipo_ordenes](#tipo_ordenes')
* [tipo_parametros](#tipo_parametros')
* [tipo_respuestas](#tipo_respuestas')
* [tipo_unidades](#tipo_unidades')
* [tipo_valoraciones](#tipo_valoraciones')
* [unidades](#unidades')
* [usuarios](#usuarios')
* [valoraciones](#valoraciones')
* [visitas](#visitas')

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
ir a [http://api-sascha.heroku.com/](http://api-sascha.heroku.com/) en tu nevegador

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

# calificaciones

[[ver json]](https://api-sascha.herokuapp.com/calificaciones)

# citas

[[ver json]](https://api-sascha.herokuapp.com/citas)

# clientes

[[ver json]](https://api-sascha.herokuapp.com/clientes)

# comentarios

[[ver json]](https://api-sascha.herokuapp.com/comentarios)

# comidas

[[ver json]](https://api-sascha.herokuapp.com/comidas)

# condicionGarantias

[[ver json]](https://api-sascha.herokuapp.com/condiciongarantias)

# contenidos

[[ver json]](https://api-sascha.herokuapp.com/contenidos)

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

# diaLaborables

[[ver json]](https://api-sascha.herokuapp.com/dialaborables)

# ejercicios

[[ver json]](https://api-sascha.herokuapp.com/ejercicios)

# empleados

[[ver json]](https://api-sascha.herokuapp.com/empleados)

# especialidades

[[ver json]](https://api-sascha.herokuapp.com/especialidades)

# especialidadeEmpleados

[[ver json]](https://api-sascha.herokuapp.com/especialidadeempleados)

# especialidadeServicios

[[ver json]](https://api-sascha.herokuapp.com/especialidadeservicios)

# estados

[[ver json]](https://api-sascha.herokuapp.com/estados)

# estadoCiviles

[[ver json]](https://api-sascha.herokuapp.com/estadociviles)

# frecuencias

[[ver json]](https://api-sascha.herokuapp.com/frecuencias)

# funcionalidades

[[ver json]](https://api-sascha.herokuapp.com/funcionalidades)

# garantiaServicios

[[ver json]](https://api-sascha.herokuapp.com/garantiaservicios)

# generos

[[ver json]](https://api-sascha.herokuapp.com/generos)

# grupoalimenticios

[[ver json]](https://api-sascha.herokuapp.com/grupoalimenticios)

# horarioEmpleados

[[ver json]](https://api-sascha.herokuapp.com/horarioempleados)

# incidencias

[[ver json]](https://api-sascha.herokuapp.com/incidencias)

# motivos

[[ver json]](https://api-sascha.herokuapp.com/motivos)

# negocios

[[ver json]](https://api-sascha.herokuapp.com/negocios)

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

# plan_dietas

[[ver json]](https://api-sascha.herokuapp.com/plandietas)

# plan_ejercicios

[[ver json]](https://api-sascha.herokuapp.com/planejercicios)

# plan_suplementos

[[ver json]](https://api-sascha.herokuapp.com/plansuplementos)

# precios

[[ver json]](https://api-sascha.herokuapp.com/precios)

# preferenciaClientes

[[ver json]](https://api-sascha.herokuapp.com/preferenciaclientes)

# promociones

[[ver json]](https://api-sascha.herokuapp.com/promociones)

# rangoEdades

[[ver json]](https://api-sascha.herokuapp.com/rangoedades)

# reclamos

[[ver json]](https://api-sascha.herokuapp.com/reclamos)

# redSociales

[[ver json]](https://api-sascha.herokuapp.com/redsociales)

# regimenDietas

[[ver json]](https://api-sascha.herokuapp.com/regimendietas)

# regimenEjercicios

[[ver json]](https://api-sascha.herokuapp.com/regimenejercicios)

# regimenSuplementos

[[ver json]](https://api-sascha.herokuapp.com/regimensuplementos)

# respuestas

[[ver json]](https://api-sascha.herokuapp.com/respuestas)

# roles

[[ver json]](https://api-sascha.herokuapp.com/roles)

# rolFuncionalidades

[[ver json]](https://api-sascha.herokuapp.com/rolfuncionalidades)

# servicios

[[ver json]](https://api-sascha.herokuapp.com/servicios)

# slides

[[ver json]](https://api-sascha.herokuapp.com/slides)

# solicitudServicios

[[ver json]](https://api-sascha.herokuapp.com/solicitudes)

# suplementos

[[ver json]](https://api-sascha.herokuapp.com/suplementos)

# tiempos

[[ver json]](https://api-sascha.herokuapp.com/tiempos)

# tipo_citas

[[ver json]](https://api-sascha.herokuapp.com/tipocitas)

# tipo_criterios

[[ver json]](https://api-sascha.herokuapp.com/tipocriterios)

# tipo_dietas

[[ver json]](https://api-sascha.herokuapp.com/tipodietas)

# tipo_incidencias

[[ver json]](https://api-sascha.herokuapp.com/tipoincidencias)

# tipo_motivos

[[ver json]](https://api-sascha.herokuapp.com/tipomotivos)

# tipo_ordenes

[[ver json]](https://api-sascha.herokuapp.com/tipoordenes)

# tipo_parametros

[[ver json]](https://api-sascha.herokuapp.com/tipoparametros)

# tipo_respuestas

[[ver json]](https://api-sascha.herokuapp.com/tiporespuestas)

# tipo_unidades

[[ver json]](https://api-sascha.herokuapp.com/tipounidades)

# tipo_valoraciones

[[ver json]](https://api-sascha.herokuapp.com/tipovaloraciones)

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

# Unidades

```
    ├─GET────/unidades        * Retorna todos.
    ├─POST───/unidades        * Guarda. 
    ├─GET────/unidad/:id      * Retorna por id.
    ├─PUT────/unidad/:id      * Actualiza.
    ├─DELETE─/unidad/:id      * Elimina.
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
