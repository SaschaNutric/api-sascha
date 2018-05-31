'use strict'

const Bookshelf   = require('../commons/bookshelf');
require('./tipo_motivo');

let Motivo = Bookshelf.Model.extend({
  tableName: 'motivo',
  idAttribute: 'id_motivo',
  tipo_motivo: function() {
    return this.belongsTo('TipoMotivo', 'id_tipo_motivo')
    			.query({ where: { 'tipo_motivo.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Motivo', Motivo);
