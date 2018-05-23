'use strict'

const Bookshelf     = require('../commons/bookshelf');
const OrdenServicio = require('./orden_servicio');
const Respuesta     = require('./respuesta');
const Motivo        = require('./motivo');



let Reclamo = Bookshelf.Model.extend({
  tableName: 'reclamo',
  idAttribute: 'id_reclamo',
  motivo: function() {
    return this.belongsTo(Motivo, 'id_motivo')
          .query({ where: { 'motivo.estatus': 1 } });
  },
  respuesta: function() {
    return this.belongsTo(Respuesta, 'id_respuesta')
          .query({ where: { 'respuesta.estatus': 1 } });
  },
  ordenServicio: function() {
    return this.hasOne(OrdenServicio, 'id_orden_servicio')
          .query({ where: { 'orden_servicio.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Reclamo', Reclamo);
