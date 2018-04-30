'use strict'

const Bookshelf = require('../commons/bookshelf');
const Respuesta = require('../models/respuesta');

const Respuestas = Bookshelf.Collection.extend({
	model: Respuesta
});

module.exports = Respuestas;
