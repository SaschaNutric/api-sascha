'use strict'

const Bookshelf = require('../commons/bookshelf');

let Negocio = Bookshelf.Model.extend({
  tableName: 'negocio',
  idAttribute: 'id_negocio'
});

module.exports = Bookshelf.model('Negocio', Negocio);