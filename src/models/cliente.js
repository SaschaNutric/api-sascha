'use strict'

const Bookshelf   = require('../commons/bookshelf');
const EstadoCivil = require('./estado_civil');
const RangoEdad   = require('./rango_edad');
const Genero   = require('./genero');

let Cliente = Bookshelf.Model.extend({
	tableName: 'cliente',
	idAttribute: 'id_cliente',
  estado_civil: function() {
    return this.belongsTo(EstadoCivil, 'id_estado_civil');
  },
  genero: function() {
    return this.belongsTo(Genero, 'id_genero');
  },
  rango_edad: function() {
    return this.belongsTo(RangoEdad, 'id_rango_edad');
  }
});

module.exports = Bookshelf.model('Cliente', Cliente);