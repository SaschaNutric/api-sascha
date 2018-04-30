'use strict'

const Bookshelf = require('../commons/bookshelf');
const Frecuencia = require('../models/frecuencia');

const Frecuencias = Bookshelf.Collection.extend({
	model: Frecuencia
});

module.exports = Frecuencias;
