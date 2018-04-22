'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoDieta = Bookshelf.Model.extend({
  tableName: 'tipo_dieta',
  idAttribute: 'id_tipo_dieta'
});

module.exports = Bookshelf.model('TipoDieta', TipoDieta);