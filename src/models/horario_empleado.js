'use strict'

const Bookshelf 		= require('../commons/bookshelf');
const Bloque_horarios 	= require('../collections/bloque_horarios');
const Dia_laborables 	= require('../collections/dia_laborables');
const Empleado 			= require('./empleado');

let Horario_empleado = Bookshelf.Model.extend({
  tableName: 'horario_empleado',
  idAttribute: 'id_horario_empleado',
  empleado: function(){
    return this.hasMany(Empleado, 'id_empleado'); 
  },
  bloque_horario: function(){
    return this.hasMany(Bloque_horarios, 'id_bloque_horario');
  },
  dia_laborable: function(){
    return this.hasMany(Dia_laborables, 'id_dia_laborable');
  }
});

module.exports = Bookshelf.model('Horario_empleado', Horario_empleado);

