'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoMotivo = Bookshelf.Model.extend({
  tableName: 'tipo_motivo',
  idAttribute: 'id_tipo_motivo'
});

module.exports = Bookshelf.model('TipoMotivo', TipoMotivo);