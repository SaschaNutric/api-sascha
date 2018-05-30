'use strict'

const Bookshelf = require('../commons/bookshelf');
const Servicio = require('./servicio');
const Parametro = require('./parametro');
const DetalleVisita = require('./detalle_visita');
const ParametroMeta = require('./parametro_meta');


let VistaVisita = Bookshelf.Model.extend({
    tableName: 'vista_visita',
    idAttribute: 'id_visita',
    parametros: function () {
        return this.hasMany(DetalleVisita, 'id_visita')
                    .query({ where: { 'estatus': 1 } });
    },
    metas: function () {
        return this.hasMany(ParametroMeta, 'id_orden_servicio', 'id_orden_servicio')
            .query({ where: { 'parametro_meta.estatus': 1 } });
    },
    detalles: function () {
        return this.hasMany(DetalleVisita, 'id_visita', 'id_visita')
            .query({ where: { 'detalle_visita.estatus': 1 } });
    }
});

module.exports = Bookshelf.model('VistaVisita', VistaVisita);