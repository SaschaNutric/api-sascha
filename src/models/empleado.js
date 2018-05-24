'use strict'

const Bookshelf        = require('../commons/bookshelf');
require('../models/horario_empleado');

let Empleado = Bookshelf.Model.extend({
  tableName: 'empleado',
  idAttribute: 'id_empleado',
  horario: function(){
    return this.hasMany('Horario_empleado', 'id_empleado')
    .query({ where: { 'horario_empleado.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Empleado', Empleado);
