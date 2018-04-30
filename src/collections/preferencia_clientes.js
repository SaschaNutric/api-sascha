'use strict'

const Bookshelf = require('../commons/bookshelf');
const Preferencia_cliente = require('../models/preferencia_cliente');

const Preferencia_clientes = Bookshelf.Collection.extend({
	model: Preferencia_cliente
});

module.exports = Preferencia_clientes;
