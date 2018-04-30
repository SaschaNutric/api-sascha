'use strict'

const Bookshelf = require('../commons/bookshelf');

let Detalle_regimen_alimento = Bookshelf.Model.extend({
  tableName: 'detalle_regimen_alimento',
  idAttribute: 'id_detalle_regimen_alimento'
});

module.exports = Bookshelf.model('Detalle_regimen_alimento', Detalle_regimen_alimento);
