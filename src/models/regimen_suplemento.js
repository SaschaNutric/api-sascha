'use strict'

const Bookshelf = require('../commons/bookshelf');

let Regimen_suplemento = Bookshelf.Model.extend({
  tableName: 'regimen_suplemento',
  idAttribute: 'id_regimen_suplemento'
});

module.exports = Bookshelf.model('Regimen_suplemento', Regimen_suplemento);
