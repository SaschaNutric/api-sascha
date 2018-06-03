'use strict'

const Bookshelf = require('../commons/bookshelf');

let VistaEstadisticoCliente = Bookshelf.Model.extend({
    tableName: 'vista_estadistico_clientes',
    idAttribute: 'id_orden_servicio',
});

module.exports = Bookshelf.model('VistaEstadisticoCliente', VistaEstadisticoCliente);