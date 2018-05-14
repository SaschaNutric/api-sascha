'use strict'

const Bookshelf 		= require('../commons/bookshelf');
require('./plan_dieta');
require('./comida');
require('./grupo_alimenticio');

let DetallePlanDieta = Bookshelf.Model.extend({
  tableName: 'detalle_plan_dieta',
  idAttribute: 'id_detalle_plan_dieta',
  plan_dieta: function () {
    return this.belongsTo('PlanDieta', 'id_plan_dieta');
  },
  comida: function () {
    return this.belongsTo('Comida', 'id_comida');
  },
  grupoAlimenticio: function () {
    return this.belongsTo('Grupo_alimenticio', 'id_grupo_alimenticio');
  }
});

module.exports = Bookshelf.model('DetallePlanDieta', DetallePlanDieta);
