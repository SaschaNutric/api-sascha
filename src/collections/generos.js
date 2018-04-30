'use strict'

const Bookshelf = require('../commons/bookshelf');
const Genero = require('../models/genero');

const Generos = Bookshelf.Collection.extend({
	model: Genero
});

module.exports = Generos;
