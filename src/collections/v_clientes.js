'use strict'

const Bookshelf   = require('../commons/bookshelf');
const ViewCliente     = require('../models/v_cliente');

const ViewClientes = Bookshelf.Collection.extend({
	model: ViewCliente
});

module.exports = ViewClientes;