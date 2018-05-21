'use strict'

const Bookshelf = require('../commons/bookshelf');

let Frecuencia = Bookshelf.Model.extend({
  tableName: 'vista_frecuencia',
  idAttribute: 'id_frecuencia'
});

module.exports = Bookshelf.model('Frecuencia', Frecuencia);
