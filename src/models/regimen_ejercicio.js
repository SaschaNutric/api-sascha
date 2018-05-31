'use strict'

const Bookshelf 	= require('../commons/bookshelf');
const Ejercicio 	= require('./ejercicio');
const Frecuencia 	= require('./frecuencia');
const Tiempo 		= require('./tiempo');

let Regimen_ejercicio = Bookshelf.Model.extend({
  tableName: 'regimen_ejercicio',
  idAttribute: 'id_regimen_ejercicio',
  ejercicio: function () {
    return this.belongsTo(Ejercicio, 'id_ejercicio')
    			.query({ where: { 'ejercicio.estatus': 1 } });
  },
  frecuencia: function () {
    return this.belongsTo(Frecuencia, 'id_frecuencia');
  },
  tiempo: function () {
    return this.belongsTo(Tiempo, 'id_tiempo')
    			     .query({ where: { 'tiempo.estatus': 1 } });
  },
});

module.exports = Bookshelf.model('Regimen_ejercicio', Regimen_ejercicio);
