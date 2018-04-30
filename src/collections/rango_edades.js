'use strict'

const Bookshelf = require('../commons/bookshelf');
const Rango_edad = require('../models/rango_edad');

const Rango_edades = Bookshelf.Collection.extend({
	model: Rango_edad
});

module.exports = Rango_edades;
