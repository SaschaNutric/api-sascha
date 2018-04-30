'use strict'

const Bookshelf = require('../commons/bookshelf');

let Parametro = Bookshelf.Model.extend({
  tableName: 'parametro',
  idAttribute: 'id_parametro'
});

module.exports = Bookshelf.model('Parametro', Parametro);
