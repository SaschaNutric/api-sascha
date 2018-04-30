'use strict'

const Bookshelf = require('../commons/bookshelf');

let Respuesta = Bookshelf.Model.extend({
  tableName: 'respuesta',
  idAttribute: 'id_respuesta'
});

module.exports = Bookshelf.model('Respuesta', Respuesta);
