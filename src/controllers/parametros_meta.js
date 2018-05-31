'use strict';

//const Parametro_metas = require('../collections/parametro_metas');
const Parametro_meta = require('../models/parametro_meta');

function getParametro_metas(req, res, next) {
    Parametro_metas.query(function (qb) {
        qb.where('parametro_meta.estatus', '=', 1);
    })
        .fetch({ columns: ['id_parametro_meta', 'id_meta', 'id_parametro', 'valor_minimo', 'valor_maximo', 'signo'] })
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'No hay dato registrados' }
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

function saveParametroMeta(req, res, next) {
    if (!req.body.id_orden_servicio ||
        !req.body.id_parametro ||
        !req.body.valor_minimo ||
        !req.body.signo) {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Petición inválida. Faltan campos en el body' }
        })
    }
    Parametro_meta.forge({
        id_orden_servicio: req.body.id_orden_servicio,
        id_parametro: req.body.id_parametro,
        valor_minimo: req.body.valor_minimo,
        valor_maximo: req.body.valor_maximo || 0,
        signo: req.body.signo
    })
        .save()
        .then(function (data) {
            res.status(200).json({
                error: false,
                data: data
            });
        })
        .catch(function (err) {
            res.status(500)
                .json({
                    error: true,
                    data: { message: err.message }
                });
        });
}

function getParametro_metaById(req, res, next) {
    const id = Number.parseInt(req.params.id);
    if (!id || id == 'NaN')
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Solicitud incorrecta' }
        });

    Parametro_meta.forge({ id_parametro_meta: id, estatus: 1 })
        .fetch()
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'dato no encontrado' }
                });
            return res.status(200).json({
                error: false,
                data: data
            });
        })
        .catch(function (err) {
            return res.status(500).json({
                error: false,
                data: { mensaje: err.message }
            })
        });
}

function updateParametroMeta(req, res, next) {
    const id = Number.parseInt(req.params.id);
    if (!id || id == 'NaN') {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Petición inválida' }
        });
    }

    Parametro_meta.forge({ id_parametro_meta: id, estatus: 1 })
        .fetch()
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'Solicitud no encontrada' }
                });
            data.save({
                valor_minimo: req.body.valor_minimo || data.get('valor_minimo'),
                valor_maximo: req.body.valor_maximo || data.get('valor_maximo'),
                signo: req.body.signo || data.get('signo')
            })
                .then(function (data) {
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

function deleteParametroMeta(req, res, next) {
    const id = Number.parseInt(req.params.id);
    if (!id || id == 'NaN') {
        return res.status(400).json({
            error: true,
            data: { mensaje: 'Petición inválida' }
        });
    }
    Parametro_meta.forge({ id_parametro_meta: id, estatus: 1 })
        .fetch()
        .then(function (data) {
            if (!data)
                return res.status(404).json({
                    error: true,
                    data: { mensaje: 'Parametro en el meta no encontrado' }
                });
            data.destroy()
                .then(function () {
                    return res.status(200).json({
                        error: false,
                        data: { mensaje: 'Meta eliminada' }
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
    getParametro_metas,
    saveParametroMeta,
    updateParametroMeta,
    deleteParametroMeta
}