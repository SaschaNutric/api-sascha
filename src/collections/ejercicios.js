'use strict'

const Bookshelf = require('../commons/bookshelf');
const Ejercicio = require('../models/ejercicio');

const Ejercicios = Bookshelf.Collection.extend({
	model: Ejercicio
});

module.exports = Ejercicios;
