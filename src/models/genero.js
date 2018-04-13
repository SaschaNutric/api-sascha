'use strict'

const Bookshelf = require('../commons/bookshelf');

let Genero = Bookshelf.Model.extend({
	tableName: 'genero',
	idAttribute: 'id_genero',
});

module.exports = Bookshelf.model('Genero', Genero);