'use strict'

const Bookshelf = require('../commons/bookshelf');

let Estado = Bookshelf.Model.extend({
	tableName: 'estado',
	idAttribute: 'id_estado',
});

module.exports = Bookshelf.model('Estado', Estado);