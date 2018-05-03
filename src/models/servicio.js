'use strict'

const Bookshelf 	   = require('../commons/bookshelf');
const Precio         = require('./precio');
const PlanDieta 	   = require('./plan_dieta');
const PlanEjercicio  = require('./plan_ejercicio');
const PlanSuplemento = require('./plan_suplemento');
const TipoDieta      = require('./tipo_dieta');
const Especialidad   = require('./especialidad');

let Servicio = Bookshelf.Model.extend({
  tableName: 'servicio',
  idAttribute: 'id_servicio',
  precio: function() {
    return this.belongsTo(Precio, 'id_precio');
  }, 
  plan_dieta: function() {
    return this.belongsTo(PlanDieta, 'id_plan_dieta');
  },
  plan_ejercicio: function() {
    return this.belongsTo(PlanEjercicio, 'id_plan_ejercicio');
  },
  plan_suplemento: function() {
    return this.belongsTo(PlanSuplemento, 'id_plan_suplemento');
  },
  especialidad: function() {
    return this.belongsTo(Especialidad, 'id_especialidad');
  }
});

module.exports = Bookshelf.model('Servicio', Servicio);
