'use strict'

const Bookshelf = require('../commons/bookshelf');

let Suplemento = Bookshelf.Model.extend({
  tableName: 'suplemento',
  idAttribute: 'id_suplemento'
});

module.exports = Bookshelf.model('Suplemento', Suplemento);
