'use strict'

const Bookshelf 	= require('../commons/bookshelf');
const Servicio  	= require('./servicio');
const Genero  		= require('./genero');
const EstadoCivil  	= require('./estado_civil');
const RangoEdad  	= require('./rango_edad');

let Promocion = Bookshelf.Model.extend({
  tableName: 'promocion',
  idAttribute: 'id_promocion',
  servicio: function() {
    return this.belongsTo(Servicio, 'id_servicio');
  },
  genero: function() {
    return this.belongsTo(Genero, 'id_genero');
  },
  estado_civil: function() {
    return this.belongsTo(EstadoCivil, 'id_estado_civil');
  },
  rango_edad: function() {
    return this.belongsTo(RangoEdad, 'id_rango_edad');
  }
});

module.exports = Bookshelf.model('Promocion', Promocion);