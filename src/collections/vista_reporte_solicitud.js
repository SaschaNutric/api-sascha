'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaReporteSolicitud = require('../models/vista_reporte_solicitud');

const VistaReporteSolicitudes = Bookshelf.Collection.extend({
    model: VistaReporteSolicitud
});

module.exports = VistaReporteSolicitudes;