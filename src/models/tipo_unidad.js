'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoUnidad = Bookshelf.Model.extend({
  tableName: 'tipo_unidad',
  idAttribute: 'id_tipo_unidad'
});

module.exports = Bookshelf.model('TipoUnidad', TipoUnidad);