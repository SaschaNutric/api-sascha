'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoParametro = Bookshelf.Model.extend({
  tableName: 'tipo_parametro',
  idAttribute: 'id_tipo_parametro'
});

module.exports = Bookshelf.model('TipoParametro', TipoParametro);