'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaCalificacionServicio = require('../models/vista_calificacion_servicio');

const VistaCalificacionServicios = Bookshelf.Collection.extend({
    model: VistaCalificacionServicio
});

module.exports = VistaCalificacionServicios;