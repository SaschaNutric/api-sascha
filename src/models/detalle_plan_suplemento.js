'use strict'

const Bookshelf = require('../commons/bookshelf');

let Detalle_plan_suplemento = Bookshelf.Model.extend({
  tableName: 'detalle_plan_suplemento',
  idAttribute: 'id_detalle_plan_suplemento'
});

module.exports = Bookshelf.model('Detalle_plan_suplemento', Detalle_plan_suplemento);
