'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./parametro');

let TipoParametro = Bookshelf.Model.extend({
  tableName: 'tipo_parametro',
  idAttribute: 'id_tipo_parametro',
    parametros: function() {
  	return this.hasMany('Parametro', 'id_tipo_parametro');
    }
});

module.exports = Bookshelf.model('TipoParametro', TipoParametro);
