'use strict'

const Bookshelf = require('../commons/bookshelf');

let Comida = Bookshelf.Model.extend({
  tableName: 'comida',
  idAttribute: 'id_comida'
});

module.exports = Bookshelf.model('Comida', Comida);
