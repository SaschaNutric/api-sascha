'use strict'

const Bookshelf = require('../commons/bookshelf');
const Ejercicio = require('./ejercicio');

let PlanEjercicio = Bookshelf.Model.extend({
  tableName: 'plan_ejercicio',
  idAttribute: 'id_plan_ejercicio',
  ejercicios: function() {
    return this.belongsToMany(Ejercicio, 'detalle_plan_ejercicio', 'id_plan_ejercicio', 'id_ejercicio')
    			.query({ where: { 'ejercicio.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('PlanEjercicio', PlanEjercicio);