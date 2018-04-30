'use strict'

const Bookshelf = require('../commons/bookshelf');

let Parametro_cliente = Bookshelf.Model.extend({
  tableName: 'parametro_cliente',
  idAttribute: 'id_parametro_cliente'
});

module.exports = Bookshelf.model('Parametro_cliente', Parametro_cliente);
