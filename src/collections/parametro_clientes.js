'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro_cliente = require('../models/parametro_cliente');

const Parametro_clientes = Bookshelf.Collection.extend({
	model: Parametro_cliente
});

module.exports = Parametro_clientes;
