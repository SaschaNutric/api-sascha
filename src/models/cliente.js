'use strict'

const Bookshelf = require('../commons/bookshelf');

const Cliente = Bookshelf.Model.extend({
	tableName: 'cliente',
	idAttribute: 'id_cliente',

});

module.exports = Cliente;