'use strict'

const Bookshelf = require('../commons/bookshelf');

let Detalle_plan_ejercicio = Bookshelf.Model.extend({
  tableName: 'detalle_plan_ejercicio',
  idAttribute: 'id_detalle_plan_ejercicio'
});

module.exports = Bookshelf.model('Detalle_plan_ejercicio', Detalle_plan_ejercicio);
