'use strict';

const Bookshelf = require('../commons/bookshelf');
const VistaEstadisticoClientes = require('../collections/vista_estadistico_clientes');
const VistaNutricionistas = require('../collections/vista_nutricionistas');
const VistaCanalEscuchas = require('../collections/vista_canal_escuchas')


function getMotivosSolicitudPreferidos(req, res, next) {

    let campos = {
        id_especialidad: req.body.id_especialidad || null,
        id_servicio: req.body.id_servicio || null,
        id_genero: req.body.id_genero || null,
        id_estado_civil: req.body.id_estado_civil || null,
        id_rango_edad: req.body.id_rango_edad || null
    }


    let rango_fecha = {
        minimo: req.body.fecha_inicial || null,
        maximo: req.body.fecha_final || null
    }

    let filtros = new Object();
    for (let item in campos) {
        if (campos.hasOwnProperty(item)) {
            if (campos[item] != null)
                filtros[item] = campos[item];
        }
    }

    VistaEstadisticoClientes.query(function (qb) {
        qb.select('motivo_descripcion')
        qb.count('id_motivo');
        qb.where(filtros);
        if (rango_fecha.minimo && rango_fecha.maximo)
            qb.where('fecha_creacion', '>=', rango_fecha.minimo)
                .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
        qb.groupBy('id_motivo', 'motivo_descripcion')
        qb.orderBy('count', 'desc')
        qb.limit(5)

    })
        .fetch()
        .then(function (preferidos) {
            VistaEstadisticoClientes.query(function (qb) {
                qb.where(filtros);
                if (rango_fecha.minimo && rango_fecha.maximo)
                    qb.where('fecha_creacion', '>=', rango_fecha.minimo)
                        .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
            })
                .count()
                .then(function (cont) {

                    let data = {
                        motivos: preferidos,
                        total: cont

                    }
                    return res.status(200).json({ error: false, data: data });

                }).catch(function (err) {
                    return res.status(500).json({ error: true, data: { mensaje: err.message } });
                });

        })
        .catch(function (err) {
            return res.status(500).json({ error: true, data: { mensaje: err.message } });
        });




}

function getVisitasByNutricionista(req, res, next){
    let id_especialidad = req.body.id_especialidad || null
    let rango_fecha = {
        minimo: req.body.fecha_inicial || null ,
        maximo : req.body.fecha_final || null
    }

    VistaNutricionistas.query( function(qb){
        qb.select('nombre_empleado');
        qb.countDistinct(' id_orden_servicio as cantidad_clientes');
        if(id_especialidad != null)
            qb.where('id_especialidad',id_especialidad)
        if (rango_fecha.minimo && rango_fecha.maximo)
            qb.where('fecha_creacion', '>=', rango_fecha.minimo)
                .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
        qb.groupBy( 'nombre_empleado')
        qb.orderBy('cantidad_clientes','DESC')

    })
    .fetch()
    .then(function(data){
        data.map(function(emp){

        })
        return res.status(200).json({ error: false, data: data });
        
    })
    .catch(function (err) {
        return res.status(500).json({ error: true, data: { mensaje: err.message } });
    });


}


function getMotivosByTipoContacto(req,res,next){
    if (!req.body.id_tipo_motivo) {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Petición inválida. Indique el tipo de contacto' }
        })
    }

    let campos = {
        id_genero: req.body.id_genero || null,
        id_estado_civil: req.body.id_estado_civil || null,
        id_rango_edad: req.body.id_rango_edad || null

    }
    
    let rango_fecha = {
        minimo: req.body.fecha_inicial || null,
        maximo: req.body.fecha_final || null
    }

    let filtros = new Object();
    for (let item in campos) {
        if (campos.hasOwnProperty(item)) {
            if (campos[item] != null)
                filtros[item] = campos[item];
        }
    }

    VistaCanalEscuchas.query(function(qb){
        qb.select('motivo_descripcion');
        qb.count('id_comentario as cantidad');
        qb.where('id_tipo_motivo', req.body.id_tipo_motivo)
        qb.where(filtros);
        if (rango_fecha.minimo && rango_fecha.maximo)
        qb.where('fecha_creacion', '>=', rango_fecha.minimo)
            .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
        qb.groupBy('motivo_descripcion')
        qb.orderBy('cantidad', 'DESC')
    })
    .fetch()
    .then(function(data){
        return res.status(200).json({ error: false, data:data });
        
    })
    .catch(function (err) {
        return res.status(500).json({ error: true, data: { mensaje: err.message } });
    });


}

module.exports = {
    getMotivosSolicitudPreferidos,
    getVisitasByNutricionista,
    getMotivosByTipoContacto
}