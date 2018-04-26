'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoCriterio = Bookshelf.Model.extend({
  tableName: 'tipo_criterio',
  idAttribute: 'id_tipo_criterio'
});

module.exports = Bookshelf.model('TipoCriterio', TipoCriterio);