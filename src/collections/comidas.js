'use strict'

const Bookshelf = require('../commons/bookshelf');
const Comida = require('../models/comida');

const Comidas = Bookshelf.Collection.extend({
	model: Comida
});

module.exports = Comidas;
