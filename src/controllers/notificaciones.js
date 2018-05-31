'use strict';

const Notificaciones = require('../collections/notificaciones');
const Notificacion = require('../models/notificacion');
const cloudinary = require('../../cloudinary');

function getNotificacionesByUsuario(req, res, next) {
    const id = Number.parseInt(req.params.id);
    if (id == 'NaN')
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Petición inválida' }
        });
    //Notificaciones.query({ where: { id_usuario: id } })
    Notificaciones.query(function(qb) {
        qb.where('id_usuario', id);
        qb.orderBy('fecha_creacion', 'DESC');
    })
        .fetch()
        .then(function (data) {
            if (data.length == 0)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'Usuario no tiene notificaciones' }
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

function deleteNotificacion(req, res, next) {
    const id = Number.parseInt(req.params.id);
    if (id == 'NaN') {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Petición inválida' }
        });
    }
    Notificacion.forge({ id_notificacion: id })
        .fetch()
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'Notificación no encontrada' }
                });

            data.destroy()
                .then(function () {
                    return res.status(200).json({
                        error: false,
                        data: { mensaje: 'Notificación eliminada' }
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
    getNotificacionesByUsuario,
    deleteNotificacion,
}