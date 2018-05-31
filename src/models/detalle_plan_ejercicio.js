'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./plan_ejercicio');
require('./ejercicio');

let Detalle_plan_ejercicio = Bookshelf.Model.extend({
  tableName: 'detalle_plan_ejercicio',
  idAttribute: 'id_detalle_plan_ejercicio',
  plan_ejercicio: function () {
    return this.belongsTo('PlanEjercicio', 'id_plan_ejercicio')
          .query({ where: { 'plan_ejercicio.estatus': 1 } });
  },
  ejercicio: function () {
    return this.belongsTo('Ejercicio', 'id_ejercicio')
    			.query({ where: { 'ejercicio.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Detalle_plan_ejercicio', Detalle_plan_ejercicio);
