'use strict'

const Bookshelf = require('../commons/bookshelf');

let Usuario = Bookshelf.Model.extend({
	tableName: 'usuario',
	idAttribute: 'id_usuario'
});

module.exports = Bookshelf.model('Usuario', Usuario);