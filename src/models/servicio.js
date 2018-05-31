'use strict'

const Bookshelf 	   = require('../commons/bookshelf');
const Precio         = require('./precio');
const PlanDieta 	   = require('./plan_dieta');
const PlanEjercicio  = require('./plan_ejercicio');
const PlanSuplemento = require('./plan_suplemento');
const Especialidad   = require('./especialidad');
const ParametroServicio = require('./parametro_servicio');
const Condicion_garantia = require('./condicion_garantia');

let Servicio = Bookshelf.Model.extend({
  tableName: 'servicio',
  idAttribute: 'id_servicio', 
  plan_dieta: function() {
    return this.belongsTo(PlanDieta, 'id_plan_dieta')
          .query({ where: { 'plan_dieta.estatus': 1 } });
  },
  plan_ejercicio: function() {
    return this.belongsTo(PlanEjercicio, 'id_plan_ejercicio')
          .query({ where: { 'plan_ejercicio.estatus': 1 } });
  },
  plan_suplemento: function() {
    return this.belongsTo(PlanSuplemento, 'id_plan_suplemento')
          .query({ where: { 'plan_suplemento.estatus': 1 } });
  },
  especialidad: function() {
    return this.belongsTo(Especialidad, 'id_especialidad')
    .query({ where: { 'especialidad.estatus': 1 } });
  },
  parametros: function() {
    return this.hasMany(ParametroServicio, 'id_servicio')
          .query({ where: { 'parametro_servicio.estatus': 1 } });
  },
  condiciones_garantia: function() {
    return this.belongsToMany(Condicion_garantia, 'garantia_servicio', 'id_servicio', 'id_condicion_garantia')
    .query({ where: { 'condicion_garantia.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Servicio', Servicio);
