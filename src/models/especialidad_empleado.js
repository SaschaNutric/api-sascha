'use strict'

const Bookshelf = require('../commons/bookshelf');

let Especialidad_empleado = Bookshelf.Model.extend({
  tableName: 'especialidad_empleado',
  idAttribute: 'id_especialidad_empleado'
});

module.exports = Bookshelf.model('Especialidad_empleado', Especialidad_empleado);
