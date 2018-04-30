'use strict'

const Bookshelf = require('../commons/bookshelf');
const Precio = require('../models/precio');

const Precios = Bookshelf.Collection.extend({
	model: Precio
});

module.exports = Precios;
