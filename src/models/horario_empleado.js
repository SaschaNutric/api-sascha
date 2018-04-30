'use strict'

const Bookshelf = require('../commons/bookshelf');

let Horario_empleado = Bookshelf.Model.extend({
  tableName: 'horario_empleado',
  idAttribute: 'id_horario_empleado'
});

module.exports = Bookshelf.model('Horario_empleado', Horario_empleado);
