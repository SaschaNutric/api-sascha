'use strict';

const TipoNotificaciones = require('../collections/tipo_notificaciones');
const TipoNotificacion = require('../models/tipo_notificacion');

function getTipoNotificaciones(req, res, next) {
    TipoNotificaciones.query(function (qb) {
        qb.where('tipo_notificacion.estatus', '=', 1);
    })
        .fetch()
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'No hay datos registrados' }
                });

            return res.status(200).json({
                error: false,
                data: data
            });
        })
        .catch(function (err) {
            return res.status(500).json({
                error: true,
                data: { mensaje: err.message }
            });
        });
}


function updateTipoNotificacion(req, res, next) {
    const id = Number.parseInt(req.params.id);
    if (!id || id == 'NaN') {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Solicitud incorrecta' }
        });
    }

    TipoNotificacion.forge({ id_tipo_notificacion: id, estatus: 1 })
        .fetch()
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'Solicitud no encontrada' }
                });
            data.save({
                mensaje: req.body.mensaje || data.get('mensaje')
            })
                .then(function () {
                    return res.status(200).json({
                        error: false,
                        data: data
                    });
                })
                .catch(function (err) {
                    return res.status(500).json({
                        error: true,
                        data: { mensaje: err.message }
                    });
                })
        })
        .catch(function (err) {
            return res.status(500).json({
                error: true,
                data: { mensaje: err.message }
            });
        })
}

module.exports = {
    getTipoNotificaciones,
    updateTipoNotificacion
}