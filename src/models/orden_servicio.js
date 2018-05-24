'use strict'

const Bookshelf = require('../commons/bookshelf');
const Solicitud = require('./solicitud_servicio');

let Orden_servicio = Bookshelf.Model.extend({
  tableName: 'orden_servicio',
  idAttribute: 'id_orden_servicio',
  solicitud: function(){
    return this.belongsTo(Solicitud, 'id_solicitud_servicio')
          .query({ where: { 'solicitud_servicio.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Orden_servicio', Orden_servicio);
