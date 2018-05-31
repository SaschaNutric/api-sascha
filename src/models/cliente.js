'use strict'

const Bookshelf   = require('../commons/bookshelf');
const EstadoCivil = require('./estado_civil');
const RangoEdad   = require('./rango_edad');
const Genero      = require('./genero');

let Cliente = Bookshelf.Model.extend({
	tableName: 'cliente',
	idAttribute: 'id_cliente',
  estado_civil: function() {
    return this.belongsTo(EstadoCivil, 'id_estado_civil')
          .query({ where: { 'estado_civil.estatus': 1 } });
  },
  genero: function() {
    return this.belongsTo(Genero, 'id_genero')
          .query({ where: { 'genero.estatus': 1 } });
  },
  rango_edad: function() {
    return this.belongsTo(RangoEdad, 'id_rango_edad')
          .query({ where: { 'rango_edad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Cliente', Cliente);