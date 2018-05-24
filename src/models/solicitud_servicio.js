'use strict'

const Bookshelf = require('../commons/bookshelf');
const Servicio  = require('./servicio');
const Cliente  = require('./cliente');

let Solicitud_servicio = Bookshelf.Model.extend({
  tableName: 'solicitud_servicio',
  idAttribute: 'id_solicitud_servicio',
  servicio: function() {
    return this.belongsTo(Servicio, 'id_servicio')
    			.query({ where: { 'servicio.estatus': 1 } });
  },
  cliente: function() {
    return this.belongsTo(Cliente, 'id_cliente')
    			.query({ where: { 'cliente.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Solicitud_servicio', Solicitud_servicio);
