'use strict'

const Bookshelf         = require('../commons/bookshelf');

let VistaReporteSolicitud = Bookshelf.Model.extend({
    tableName: 'vista_reporte_solicitud',
    idAttribute: 'id_solicitud_servicio',
});

module.exports = Bookshelf.model('VistaReporteSolicitud', VistaReporteSolicitud);