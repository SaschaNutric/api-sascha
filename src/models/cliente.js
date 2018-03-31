'use strict'

const Bookshelf = require('../commons/bookshelf');

let Cliente = Bookshelf.Model.extend({
	tableName: 'cliente',
	idAttribute: 'id_cliente',

});

module.exports = Bookshelf.model('Cliente', Cliente);