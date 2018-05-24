'use strict'

const Bookshelf = require('../commons/bookshelf');
const Suplemento = require('./suplemento');

let PlanSuplemento = Bookshelf.Model.extend({
  tableName: 'plan_suplemento',
  idAttribute: 'id_plan_suplemento',
  suplementos: function () {
    return this.belongsToMany(Suplemento, 'detalle_plan_suplemento', 'id_plan_suplemento', 'id_suplemento')
    			.query({ where: { 'suplemento.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('PlanSuplemento', PlanSuplemento);