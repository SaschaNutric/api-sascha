'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoDieta = require('./tipo_dieta');
const Comida    = require('./comida');
require('./detalle_plan_dieta');

let PlanDieta = Bookshelf.Model.extend({
  tableName: 'plan_dieta',
  idAttribute: 'id_plan_dieta',
  tipo_dieta: function() {
    return this.belongsTo(TipoDieta, 'id_tipo_dieta');
  },
  detalle: function() {
    return this.hasMany('DetallePlanDieta', 'id_plan_dieta');
  }
});

module.exports = Bookshelf.model('PlanDieta', PlanDieta);