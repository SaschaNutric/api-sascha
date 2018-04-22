'use strict'

const Bookshelf 	   = require('../commons/bookshelf');
const PlanDieta 	   = require('./plan_dieta');
const PlanEjercicio  = require('./plan_ejercicio');
const PlanSuplemento = require('./plan_suplemento');
const TipoDieta      = require('./tipo_dieta');

let Servicio = Bookshelf.Model.extend({
  tableName: 'servicio',
  idAttribute: 'id_servicio',
  plan_dieta: function() {
    return this.hasOne(PlanDieta, 'id_plan_dieta');
  },  
  plan_ejercicio: function() {
    return this.hasOne(PlanEjercicio, 'id_plan_ejercicio');
  },  
  plan_suplemento: function() {
    return this.hasOne(PlanSuplemento, 'id_plan_suplemento');
  }
});

module.exports = Bookshelf.model('Servicio', Servicio);
