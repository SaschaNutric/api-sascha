'use strict'

const Bookshelf = require('../commons/bookshelf');
const Alimento = require('./alimento');
const DetallePlanDieta = require('./detalle_plan_dieta');

let Regimen_dieta = Bookshelf.Model.extend({
  tableName: 'regimen_dieta',
  idAttribute: 'id_regimen_dieta',
  alimentos: function () {
    return this.belongsToMany(Alimento, 'detalle_regimen_alimento', 'id_regimen_dieta', 'id_alimento')
    			.query({ where: { 'alimento.estatus': 1 } });
  },
  detalle: function () {
    return this.belongsTo(DetallePlanDieta, 'id_detalle_plan_dieta')
    			.query({ where: { 'detalle_plan_dieta.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Regimen_dieta', Regimen_dieta);
