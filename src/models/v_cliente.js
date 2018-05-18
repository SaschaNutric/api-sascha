'use strict'

const Bookshelf = require('../commons/bookshelf');

let ViewCliente = Bookshelf.Model.extend({
	tableName: 'vista_cliente',
	idAttribute: 'id_cliente',
	perfil: function () {
		return this.hasMany('Parametro_cliente', 'id_cliente');
	}
});

module.exports = Bookshelf.model('ViewCliente', ViewCliente);