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
    Notificaciones.query({ where: { id_usuario: id } })
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

function deleteNegocio(req, res, next) {
    const id = Number.parseInt(req.params.id);
    if (!id || id == 'NaN') {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Solicitud incorrecta' }
        });
    }
    Negocio.forge({ id_negocio: id, estatus: 1 })
        .fetch()
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'Solicitud no encontrad0' }
                });

            data.save({ estatus: 0 })
                .then(function () {
                    return res.status(200).json({
                        error: false,
                        data: { mensaje: 'Registro eliminado' }
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
    deleteNegocio
}