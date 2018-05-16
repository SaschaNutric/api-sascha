'use strict'

const Bookshelf 		= require('../commons/bookshelf');
const Bloque_horarios 	= require('../collections/bloque_horarios');
const Dia_laborables 	= require('../collections/dia_laborables');
const Empleado 			= require('./empleado');

let Horario_empleado = Bookshelf.Model.extend({
  tableName: 'horario_empleado',
  idAttribute: 'id_horario',
  idAttribute: 'id_empleado',
  empleado: function(){
    return this.belongsTo(Empleado, 'id_empleado'); 
  },
  bloque_horarios: function(){
    return this.hasMany(Bloque_horarios, 'id_bloque_horario');
  },
  dia_laborables: function(){
    return this.hasMany(Dia_laborables, 'id_dia_laborable');
  }
});

module.exports = Bookshelf.model('Horario_empleado', Horario_empleado);

