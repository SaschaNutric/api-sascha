'use strict';

const Bookshelf = require('../commons/bookshelf');
const VistaEstadisticoClientes = require('../collections/vista_estadistico_clientes');
const VistaNutricionistas = require('../collections/vista_nutricionistas');
const VistaCanalEscuchas = require('../collections/vista_canal_escuchas');
const VistaReclamos = require('../collections/vista_reclamos');
const VistaCalificacionServicios = require('../collections/vista_calificacion_servicios');
const VistaCalificacionVisitas = require('../collections/vista_calificacion_visitas');
const TipoCriterios = require('../collections/tipo_criterios')


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

function getVisitasByNutricionista(req, res, next) {
    let id_especialidad = req.body.id_especialidad || null
    let rango_fecha = {
        minimo: req.body.fecha_inicial || null,
        maximo: req.body.fecha_final || null
    }

    VistaNutricionistas.query(function (qb) {
        qb.select('nombre_empleado');
        qb.countDistinct(' id_orden_servicio as cantidad_clientes');
        if (id_especialidad != null)
            qb.where('id_especialidad', id_especialidad)
        if (rango_fecha.minimo && rango_fecha.maximo)
            qb.where('fecha_creacion', '>=', rango_fecha.minimo)
                .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
        qb.groupBy('nombre_empleado')
        qb.orderBy('cantidad_clientes', 'DESC')

    })
        .fetch()
        .then(function (data) {
            data.map(function (emp) {

            })
            return res.status(200).json({ error: false, data: data });

        })
        .catch(function (err) {
            return res.status(500).json({ error: true, data: { mensaje: err.message } });
        });


}


function getMotivosByTipoContacto(req, res, next) {
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
    VistaCanalEscuchas.query(function (qb) {
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
        .then(function (data) {
            return res.status(200).json({ error: false, data: data });

        })
        .catch(function (err) {
            return res.status(500).json({ error: true, data: { mensaje: err.message } });
        });


}

function getReclamosByRespuesta(req, res, next) {
    let campos = {
        id_especialidad: req.body.id_especialidad || null,
        id_servicio: req.body.id_servicio || null,
        id_genero: req.body.id_genero || null,
        id_estado_civil: req.body.id_estado_civil || null,
        id_rango_edad: req.body.id_rango_edad || null,
        id_empleado: req.body.id_empleado || null
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
    let query = `select motivo_descripcion, 
                sum(CASE  WHEN aprobado     
                       THEN 1  
                 		ELSE 0
                  END) as aprobados,
             sum(CASE  WHEN aprobado      
                        THEN 0  
                  		ELSE 1
                   END) as rechazados
                from vista_reclamo
                WHERE `
    if (filtros.id_genero) query += `id_genero = ${filtros.id_genero} AND `
    if (filtros.id_especialidad) query += `id_especialidad = ${filtros.id_especialidad} AND `
    if (filtros.id_servicio) query += `id_servicio= ${filtros.id_servicio} AND `
    if (filtros.id_rango_edad) query += `id_rango_edad = ${filtros.id_rango_edad} AND `
    if (filtros.id_empleado) query += `id_empleado = ${filtros.id_empleado} AND `
    if (filtros.id_estado_civil) query += `id_estado_civil = ${filtros.id_estado_civil} AND `
    if (rango_fecha.minimo && rango_fecha.maximo) query += `fecha_creacion >= ${rango_fecha.minimo} AND fecha_creacion >=  ${rango_fecha.maximo} AND `
    query += ` id_reclamo > 0  group by motivo_descripcion`
    Bookshelf.knex.raw(query)
        .then(function (data) {
            return res.status(200).json({ error: false, data: data });

        }).catch(function (err) {
            return res.status(500).json({ error: true, data: { mensaje: err.message } });
        });

}

function getCalificacionesbyTipoDeValoracion(req, res, next) {
    if (!req.body.id_tipo_criterio) {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Petición inválida. Indique el tipo de criterio' }
        })
    }

    let tipo_criterio = req.body.id_tipo_criterio;

    let campos = {
        id_especialidad: req.body.id_especialidad || null,
        id_servicio: req.body.id_servicio || null

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

    let criterios = {}
    let valoraciones = {}

    TipoCriterios.query(function (qb) {
        qb.where("id_tipo_criterio", tipo_criterio)
    }).fetch({ withRelated: ['criterios', 'tipo_valoracion', 'tipo_valoracion.valoraciones'] })
        .then(function (data) {
            let data_json = data.toJSON()
            data_json.map(function (c) {

                c.criterios.map(function (cri) {
                    let valoraciones = {} 
                    c.tipo_valoracion.valoraciones.map(function (val) {
                        valoraciones[val.nombre] = 0
                    })
                    criterios[cri.nombre] = valoraciones
                })
            })
            if (tipo_criterio == 1) {
                VistaCalificacionServicios.query(function (qb) {
                    qb.select('nombre_criterio', 'valor');
                    qb.count('valor as cantidad')
                    qb.where(filtros)
                    if (rango_fecha.minimo && rango_fecha.maximo)
                        qb.where('fecha_creacion', '>=', rango_fecha.minimo)
                            .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
                    qb.groupBy('nombre_criterio', 'valor')
                    qb.orderBy('nombre_criterio')
                })
                    .fetch()
                    .then(function (data) {
                        let calificacion = data.toJSON();
                        calificacion.map(function (cal) {
                            criterios[cal.nombre_criterio][cal.valor] = Number.parseInt(cal.cantidad)
                        })
                        return res.status(200).json({ error: false, data: criterios });

                    }).catch(function (err) {
                        return res.status(500).json({ error: true, data: { mensaje: err.message } });
                    });
            } else {
                VistaCalificacionVisitas.query(function (qb) {
                    qb.select('nombre_criterio', 'valor');
                    qb.count('valor as cantidad')
                    qb.where(filtros)
                    if (rango_fecha.minimo && rango_fecha.maximo)
                        qb.where('fecha_creacion', '>=', rango_fecha.minimo)
                            .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
                    qb.groupBy('nombre_criterio', 'valor')
                    qb.orderBy('nombre_criterio')
                }).fetch()
                    .then(function (data) {
                        let calificacion = data.toJSON();
                        calificacion.map(function (cal) {
                            criterios[cal.nombre_criterio][cal.valor] = Number.parseInt(cal.cantidad)
                            console.log(criterios)
                        })
                        return res.status(200).json({ error: false, data: criterios });

                    }).catch(function (err) {
                        return res.status(500).json({ error: true, data: { mensaje: err.message } });
                    });

            }

        }).catch(function (err) {
            return res.status(500).json({ error: true, data: { mensaje: err.message } });
        });

}


module.exports = {
    getMotivosSolicitudPreferidos,
    getVisitasByNutricionista,
    getMotivosByTipoContacto,
    getReclamosByRespuesta,
    getCalificacionesbyTipoDeValoracion
}