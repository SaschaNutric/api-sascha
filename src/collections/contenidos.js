'use strict'

const Bookshelf = require('../commons/bookshelf');
const Contenido = require('../models/contenido');

const Contenidos = Bookshelf.Collection.extend({
	model: Contenido
});

module.exports = Contenidos;
