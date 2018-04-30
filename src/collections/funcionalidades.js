'use strict'

const Bookshelf = require('../commons/bookshelf');
const Funcionalidad = require('../models/funcionalidad');

const Funcionalidades = Bookshelf.Collection.extend({
	model: Funcionalidad
});

module.exports = Funcionalidades;
