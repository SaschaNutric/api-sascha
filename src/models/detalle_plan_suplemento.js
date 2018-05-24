'use strict'

const Bookshelf = require('../commons/bookshelf');
const Suplemento = require('./suplemento');

let Detalle_plan_suplemento = Bookshelf.Model.extend({
  tableName: 'detalle_plan_suplemento',
  idAttribute: 'id_detalle_plan_suplemento',
  suplemento: function () {
    return this.belongsTo(Suplemento, 'id_suplemento')
    			.query({ where: { 'suplemento.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Detalle_plan_suplemento', Detalle_plan_suplemento);
