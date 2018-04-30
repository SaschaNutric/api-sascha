'use strict'

const Bookshelf = require('../commons/bookshelf');

let Criterio = Bookshelf.Model.extend({
  tableName: 'criterio',
  idAttribute: 'id_criterio'
});

module.exports = Bookshelf.model('Criterio', Criterio);
