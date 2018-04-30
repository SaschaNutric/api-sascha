'use strict'

const Bookshelf = require('../commons/bookshelf');

let Orden_servicio = Bookshelf.Model.extend({
  tableName: 'orden_servicio',
  idAttribute: 'id_orden_servicio'
});

module.exports = Bookshelf.model('Orden_servicio', Orden_servicio);
