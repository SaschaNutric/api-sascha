'use strict'

const Bookshelf = require('../commons/bookshelf');
const Regimen_ejercicio = require('../models/regimen_ejercicio');

const Regimen_ejercicios = Bookshelf.Collection.extend({
	model: Regimen_ejercicio
});

module.exports = Regimen_ejercicios;
