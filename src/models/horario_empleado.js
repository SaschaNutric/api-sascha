'use strict'

const Bookshelf 		  = require('../commons/bookshelf');
const Bloque_horario 	= require('./bloque_horario');
const Dia_laborable 	= require('./dia_laborable');
require('./empleado');

let Horario_empleado = Bookshelf.Model.extend({
  tableName: 'horario_empleado',
  idAttribute: 'id_horario_empleado',
  empleado: function(){
    return this.belongsTo('Empleado', 'id_empleado')
          .query({ where: { 'empleado.estatus': 1 } });
  },
  bloque_horario: function(){
    return this.belongsTo(Bloque_horario, 'id_bloque_horario')
          .query({ where: { 'bloque_horario.estatus': 1 } });
  },
  dia_laborable: function(){
    return this.belongsTo(Dia_laborable, 'id_dia_laborable')
          .query({ where: { 'dia_laborable.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Horario_empleado', Horario_empleado);

