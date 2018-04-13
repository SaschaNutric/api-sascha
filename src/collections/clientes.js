'use strict'

const Bookshelf   = require('../commons/bookshelf');
const Cliente     = require('../models/cliente');

const Clientes = Bookshelf.Collection.extend({
	model: Cliente
});

module.exports = Clientes;