'use strict'

const Bookshelf = require('../commons/bookshelf');

let Comentario = Bookshelf.Model.extend({
  tableName: 'comentario',
  idAttribute: 'id_comentario'
});

module.exports = Bookshelf.model('Comentario', Comentario);
