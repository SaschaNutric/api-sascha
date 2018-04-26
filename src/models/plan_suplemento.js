'use strict'

const Bookshelf = require('../commons/bookshelf');

let PlanSuplemento = Bookshelf.Model.extend({
  tableName: 'plan_suplemento',
  idAttribute: 'id_plan_suplemento',
});

module.exports = Bookshelf.model('PlanSuplemento', PlanSuplemento);