'use strict'

const Bookshelf 		= require('../commons/bookshelf');
require('./plan_dieta');
require('./comida');
require('./grupo_alimenticio');

let DetallePlanDieta = Bookshelf.Model.extend({
  tableName: 'detalle_plan_dieta',
  idAttribute: 'id_detalle_plan_dieta',
  plan_dieta: function () {
    return this.belongsTo('PlanDieta', 'id_plan_dieta')
          .query({ where: { 'plan_dieta.estatus': 1 } });
  },
  comida: function () {
    return this.belongsTo('Comida', 'id_comida')
          .query({ where: { 'comida.estatus': 1 } });
  },
  grupoAlimenticio: function () {
    return this.belongsTo('Grupo_alimenticio', 'id_grupo_alimenticio')
          .query({ where: { 'grupo_alimenticio.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('DetallePlanDieta', DetallePlanDieta);
