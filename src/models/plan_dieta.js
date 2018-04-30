'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoDieta = require('./tipo_dieta');

let PlanDieta = Bookshelf.Model.extend({
  tableName: 'plan_dieta',
  idAttribute: 'id_plan_dieta',
  tipo_dieta: function() {
    return this.belongsTo(TipoDieta, 'id_tipo_dieta');
  }
});

module.exports = Bookshelf.model('PlanDieta', PlanDieta);