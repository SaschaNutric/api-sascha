'use strict'

const Bookshelf 		= require('../commons/bookshelf');
const PlanDieta 		= require('./plan_dieta');
const Comida 			= require('./comida');
const GrupoAlimenticio 	= require('./grupo_alimenticio');

let Detalle_plan_dieta = Bookshelf.Model.extend({
  tableName: 'detalle_plan_dieta',
  idAttribute: 'id_detalle_plan_dieta',
  plan_dieta: function() {
    return this.belongsTo(PlanDieta, 'id_plan_dieta');
  },
  comida: function() {
    return this.belongsTo(Comida, 'id_comida');
  },
  grupo_alimenticio: function() {
    return this.belongsTo(GrupoAlimenticio, 'id_grupo_alimenticio');
  }
});

module.exports = Bookshelf.model('Detalle_plan_dieta', Detalle_plan_dieta);
