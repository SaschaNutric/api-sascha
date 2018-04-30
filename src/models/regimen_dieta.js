'use strict'

const Bookshelf = require('../commons/bookshelf');

let Regimen_dieta = Bookshelf.Model.extend({
  tableName: 'regimen_dieta',
  idAttribute: 'id_regimen_dieta'
});

module.exports = Bookshelf.model('Regimen_dieta', Regimen_dieta);
