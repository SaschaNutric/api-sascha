'use strict'

const Bookshelf = require('../commons/bookshelf');

let Tipo_comentario = Bookshelf.Model.extend({
  tableName: 'tipo_comentario',
  idAttribute: 'id_tipo_comentario'
});

module.exports = Bookshelf.model('Tipo_comentario', Tipo_comentario);
