'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaCalificacionVisita = require('../models/vista_calificacion_visita');

const VistaCalificacionVisitas = Bookshelf.Collection.extend({
    model: VistaCalificacionVisita
});

module.exports = VistaCalificacionVisitas;