'use strict'

const Bookshelf     = require('../commons/bookshelf');
const OrdenServicio = require('./orden_servicio');
const Respuesta     = require('./respuesta');
const Motivo        = require('./motivo');

let Reclamo = Bookshelf.Model.extend({
  tableName: 'reclamo',
  idAttribute: 'id_reclamo',
  motivo: function() {
    return this.belongsTo(Motivo, 'id_motivo');
  },
  respuesta: function() {
    return this.belongsTo(Respuesta, 'id_respuesta');
  },
  ordenServicio: function() {
    return this.hasOne(OrdenServicio, 'id_orden_servicio');
  }
});

module.exports = Bookshelf.model('Reclamo', Reclamo);
