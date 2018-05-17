'use strict'

const Bookshelf 		  = require('../commons/bookshelf');
const Bloque_horario 	= require('./bloque_horario');
const Dia_laborable 	= require('./dia_laborable');
require('./empleado');

let Horario_empleado = Bookshelf.Model.extend({
  tableName: 'horario_empleado',
  idAttribute: 'id_horario_empleado',
  empleado: function(){
    return this.belongsTo('Empleado', 'id_empleado');
  },
  bloque_horario: function(){
    return this.belongsTo(Bloque_horario, 'id_bloque_horario');
  },
  dia_laborable: function(){
    return this.belongsTo(Dia_laborable, 'id_dia_laborable');
  }
});

module.exports = Bookshelf.model('Horario_empleado', Horario_empleado);

