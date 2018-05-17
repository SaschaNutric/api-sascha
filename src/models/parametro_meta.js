'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro = require('./parametro');
const OrdenServicio = require('./orden_servicio');

let ParametroMeta = Bookshelf.Model.extend({
    tableName: 'parametro_meta',
    idAttribute: 'id_parametro_meta',
    parametro: function () {
        return this.belongsTo(Parametro, 'id_parametro');
    },
    orden_servicio: function () {
        return this.belongsTo(OrdenServicio, 'id_orden_servicio');
    }
});

module.exports = Bookshelf.model('ParametroMeta', ParametroMeta);
