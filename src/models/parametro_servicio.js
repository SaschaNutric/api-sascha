'use strict'

const Bookshelf = require('../commons/bookshelf');

let Parametro_servicio = Bookshelf.Model.extend({
  tableName: 'parametro_servicio',
  idAttribute: 'id_parametro_servicio'
});

module.exports = Bookshelf.model('Parametro_servicio', Parametro_servicio);
