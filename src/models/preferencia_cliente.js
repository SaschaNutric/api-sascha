'use strict'

const Bookshelf = require('../commons/bookshelf');

let Preferencia_cliente = Bookshelf.Model.extend({
  tableName: 'preferencia_cliente',
  idAttribute: 'id_preferencia_cliente'
});

module.exports = Bookshelf.model('Preferencia_cliente', Preferencia_cliente);
