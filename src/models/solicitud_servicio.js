'use strict'

const Bookshelf = require('../commons/bookshelf');

let Solicitud_servicio = Bookshelf.Model.extend({
  tableName: 'solicitud_servicio',
  idAttribute: 'id_solicitud_servicio'
});

module.exports = Bookshelf.model('Solicitud_servicio', Solicitud_servicio);
