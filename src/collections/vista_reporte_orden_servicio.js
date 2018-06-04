'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaReporteOrdenServicio = require('../models/vista_reporte_orden_servicio');

const VistaReporteOrdenServicios = Bookshelf.Collection.extend({
    model: VistaReporteOrdenServicio
});

module.exports = VistaReporteOrdenServicios;