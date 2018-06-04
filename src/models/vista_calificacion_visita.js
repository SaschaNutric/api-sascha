'use strict'

const Bookshelf         = require('../commons/bookshelf');

let VistaCalificacionVisita = Bookshelf.Model.extend({
    tableName: 'vista_calificacion_visita',
    idAttribute: 'id_calificacion',
});

module.exports = Bookshelf.model('VistaCalificacionVisita', VistaCalificacionVisita);