'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./suplemento');
 require('./plan_suplemento');


let Detalle_plan_suplemento = Bookshelf.Model.extend({
  tableName: 'detalle_plan_suplemento',
  idAttribute: 'id_detalle_plan_suplemento',
  plan_suplemento: function () {
    return this.belongsTo('PlanSuplemento', 'id_plan_suplemento')
          .query({ where: { 'plan_suplemento.estatus': 1 } });
  },
  suplemento: function () {
    return this.belongsTo('Suplemento', 'id_suplemento')
    			.query({ where: { 'suplemento.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Detalle_plan_suplemento', Detalle_plan_suplemento);
