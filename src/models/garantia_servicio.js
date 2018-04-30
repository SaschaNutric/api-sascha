'use strict'

const Bookshelf 		= require('../commons/bookshelf');
const Servicio  		= require('./servicio');
const CondicionGarantia = require('./condicion_garantia');

let Garantia_servicio = Bookshelf.Model.extend({
  tableName: 'garantia_servicio',
  idAttribute: 'id_garantia_servicio',
  servicio: function() {
    return this.belongsTo(Servicio, 'id_servicio');
  },
  condicion_garantia: function() {
    return this.belongsTo(CondicionGarantia, 'id_condicion_garantia');
  }
});

module.exports = Bookshelf.model('Garantia_servicio', Garantia_servicio);
