'use strict'

const Bookshelf = require('../commons/bookshelf');

let PlanEjercicio = Bookshelf.Model.extend({
  tableName: 'plan_ejercicio',
  idAttribute: 'id_plan_ejercicio'
});

module.exports = Bookshelf.model('PlanEjercicio', PlanEjercicio);