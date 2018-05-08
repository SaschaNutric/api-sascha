'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./motivo');

let TipoMotivo = Bookshelf.Model.extend({
  tableName: 'tipo_motivo',
  idAttribute: 'id_tipo_motivo',
  motivos: function () {
    return this.hasMany('Motivo', 'id_tipo_motivo');
  }
});

module.exports = Bookshelf.model('TipoMotivo', TipoMotivo);