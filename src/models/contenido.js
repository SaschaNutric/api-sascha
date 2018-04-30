'use strict'

const Bookshelf = require('../commons/bookshelf');

let Contenido = Bookshelf.Model.extend({
  tableName: 'contenido',
  idAttribute: 'id_contenido'
});

module.exports = Bookshelf.model('Contenido', Contenido);
