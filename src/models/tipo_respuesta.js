'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./respuesta');

let TipoRespuesta = Bookshelf.Model.extend({
  tableName: 'tipo_respuesta',
  idAttribute: 'id_tipo_respuesta',
  respuestas: function () {
    return this.hasMany('Respuesta', 'id_tipo_respuesta')
    .query({ where: { 'respuesta.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('TipoRespuesta', TipoRespuesta);