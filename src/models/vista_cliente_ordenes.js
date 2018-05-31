'use strict'

const Bookshelf = require('../commons/bookshelf');

let ViewClienteOrdenes = Bookshelf.Model.extend({
	tableName: 'vista_cliente_ordenes',
	idAttribute: 'id_cliente',

});

module.exports = Bookshelf.model('ViewClienteOrdenes', ViewClienteOrdenes);