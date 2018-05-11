'use strict'

const Bookshelf = require('../commons/bookshelf');
const Servicio  = require('./servicio');

let Solicitud_servicio = Bookshelf.Model.extend({
  tableName: 'solicitud_servicio',
  idAttribute: 'id_solicitud_servicio',
  servicio: function() {
    return this.belongsTo(Servicio, 'id_servicio');
  }
});

module.exports = Bookshelf.model('Solicitud_servicio', Solicitud_servicio);
