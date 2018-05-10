'use strict'

const Bookshelf        = require('../commons/bookshelf');
const Horario_Empleado = require('../models/horario_empleado');

let Empleado = Bookshelf.Model.extend({
  tableName: 'empleado',
  idAttribute: 'id_empleado',
  horario: function(){
    return this.hasMany(Horario_Empleado, 'id_empleado');
  }
});

module.exports = Bookshelf.model('Empleado', Empleado);
