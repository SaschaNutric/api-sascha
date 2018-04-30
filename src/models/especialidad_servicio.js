'use strict'

const Bookshelf = require('../commons/bookshelf');

let Especialidad_servicio = Bookshelf.Model.extend({
  tableName: 'especialidad_servicio',
  idAttribute: 'id_especialidad_servicio'
});

module.exports = Bookshelf.model('Especialidad_servicio', Especialidad_servicio);
