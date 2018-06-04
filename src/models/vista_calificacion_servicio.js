'use strict'

const Bookshelf         = require('../commons/bookshelf');

let VistaCalificacionServicio = Bookshelf.Model.extend({
    tableName: 'vista_calificacion_servicio',
    idAttribute: 'id_calificacion',
});

module.exports = Bookshelf.model('VistaCalificacionServicio', VistaCalificacionServicio);