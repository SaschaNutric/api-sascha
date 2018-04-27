'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoValoracion = Bookshelf.Model.extend({
  tableName: 'tipo_valoracion',
  idAttribute: 'id_tipo_valoracion'
});

module.exports = Bookshelf.model('TipoValoracion', TipoValoracion);