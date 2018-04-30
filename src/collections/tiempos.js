'use strict'

const Bookshelf = require('../commons/bookshelf');
const Tiempo = require('../models/tiempo');

const Tiempos = Bookshelf.Collection.extend({
	model: Tiempo
});

module.exports = Tiempos;
