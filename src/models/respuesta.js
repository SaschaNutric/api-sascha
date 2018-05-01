'use strict'

const Bookshelf 	= require('../commons/bookshelf');
const TipoRespuesta = require('./tipo_respuesta');

let Respuesta = Bookshelf.Model.extend({
  tableName: 'respuesta',
  idAttribute: 'id_respuesta',
  tipo_respuesta: function() {
    return this.belongsTo(TipoRespuesta, 'id_tipo_respuesta');
  }
});

module.exports = Bookshelf.model('Respuesta', Respuesta);
