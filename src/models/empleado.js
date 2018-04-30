'use strict'

const Bookshelf = require('../commons/bookshelf');

let Empleado = Bookshelf.Model.extend({
  tableName: 'empleado',
  idAttribute: 'id_empleado'
});

module.exports = Bookshelf.model('Empleado', Empleado);
