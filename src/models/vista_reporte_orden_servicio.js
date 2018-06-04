'use strict'

const Bookshelf         = require('../commons/bookshelf');

let VistaReporteOrdenServicio = Bookshelf.Model.extend({
    tableName: 'vista_orden_servicio',
    idAttribute: 'id_orden_servicio',
});

module.exports = Bookshelf.model('VistaReporteOrdenServicio', VistaReporteOrdenServicio);