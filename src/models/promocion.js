'use strict'

const Bookshelf = require('../commons/bookshelf');

let Promocion = Bookshelf.Model.extend({
  tableName: 'promocion',
  idAttribute: 'id_promocion'
});

module.exports = Bookshelf.model('Promocion', Promocion);