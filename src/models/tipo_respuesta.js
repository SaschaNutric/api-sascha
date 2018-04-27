'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoRespuesta = Bookshelf.Model.extend({
  tableName: 'tipo_respuesta',
  idAttribute: 'id_tipo_respuesta'
});

module.exports = Bookshelf.model('TipoRespuesta', TipoRespuesta);