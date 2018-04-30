'use strict'

const Bookshelf 	= require('../commons/bookshelf');
const TipoParametro = require('./tipo_parametro');
const Unidad  		= require('./unidad');

let Parametro = Bookshelf.Model.extend({
  tableName: 'parametro',
  idAttribute: 'id_parametro',
  tipo_parametro: function() {
    return this.belongsTo(TipoParametro, 'id_tipo_parametro');
  },
  unidad: function() {
    return this.belongsTo(Unidad, 'id_unidad');
  }
});

module.exports = Bookshelf.model('Parametro', Parametro);

