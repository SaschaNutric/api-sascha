'use strict'

const Bookshelf 		= require('../commons/bookshelf');
const Servicio  		= require('./servicio');
const CondicionGarantia = require('./condicion_garantia');

let Garantia_servicio = Bookshelf.Model.extend({
  tableName: 'garantia_servicio',
  idAttribute: 'id_garantia_servicio',
  servicio: function() {
    return this.belongsTo(Servicio, 'id_servicio')
    			.query({ where: { 'servicio.estatus': 1 } });
  },
  condicion_garantia: function() {
    return this.belongsTo(CondicionGarantia, 'id_condicion_garantia')
    			.query({ where: { 'condicion_garantia.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Garantia_servicio', Garantia_servicio);
