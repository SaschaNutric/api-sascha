'use strict'

const Bookshelf = require('../commons/bookshelf');

let ViewCliente = Bookshelf.Model.extend({
	tableName: 'v_cliente',
	idAttribute: 'id_cliente',

});

module.exports = Bookshelf.model('ViewCliente', ViewCliente);