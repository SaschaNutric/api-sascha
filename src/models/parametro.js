'use strict'

const Bookshelf 	= require('../commons/bookshelf');
const TipoParametro = require('./tipo_parametro');
const Unidad  		= require('./unidad');

let Parametro = Bookshelf.Model.extend({
  tableName: 'parametro',
  idAttribute: 'id_parametro',
  tipo_parametro: function() {
    return this.belongsTo(TipoParametro, 'id_tipo_parametro')
    			.query({ where: { 'tipo_parametro.estatus': 1 } });
  },
  unidad: function() {
    return this.belongsTo(Unidad, 'id_unidad')
    			.query({ where: { 'unidad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Parametro', Parametro);

