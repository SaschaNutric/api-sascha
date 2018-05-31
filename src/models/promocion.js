'use strict'

const Bookshelf 	= require('../commons/bookshelf');
const Servicio  	= require('./servicio');
const Genero  		= require('./genero');
const EstadoCivil = require('./estado_civil');
const RangoEdad  	= require('./rango_edad');
const ParametroPromocion = require('./parametro_promocion');

let Promocion = Bookshelf.Model.extend({
  tableName: 'promocion',
  idAttribute: 'id_promocion',
  servicio: function() {
    return this.belongsTo(Servicio, 'id_servicio')
          .query({ where: { 'servicio.estatus': 1 } });
  },
  genero: function() {
    return this.belongsTo(Genero, 'id_genero')
          .query({ where: { 'genero.estatus': 1 } });
  },
  estado_civil: function() {
    return this.belongsTo(EstadoCivil, 'id_estado_civil')
          .query({ where: { 'estado_civil.estatus': 1 } });
  },
  rango_edad: function() {
    return this.belongsTo(RangoEdad, 'id_rango_edad')
          .query({ where: { 'rango_edad.estatus': 1 } });
  },
  parametros: function() {
    return this.hasMany(ParametroPromocion, 'id_promocion')
    .query({ where: { 'parametro_promocion.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Promocion', Promocion);