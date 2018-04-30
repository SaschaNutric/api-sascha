'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro = require('./parametro');
const Cliente  	= require('./cliente');

let Parametro_cliente = Bookshelf.Model.extend({
  tableName: 'parametro_cliente',
  idAttribute: 'id_parametro_cliente',
  parametro: function() {
    return this.belongsTo(Parametro, 'id_parametro');
  },
  cliente: function() {
    return this.belongsTo(Cliente, 'id_cliente');
  }
});

module.exports = Bookshelf.model('Parametro_cliente', Parametro_cliente);
