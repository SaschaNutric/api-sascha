'use strict'

const Bookshelf 	= require('../commons/bookshelf');
const TipoMotivo = require('./tipo_motivo');

let Respuesta = Bookshelf.Model.extend({
  tableName: 'respuesta',
  idAttribute: 'id_respuesta',
  tipo_respuesta: function() {
    return this.belongsTo(TipoMotivo, 'id_tipo_respuesta');
  }
});

module.exports = Bookshelf.model('Respuesta', Respuesta);
