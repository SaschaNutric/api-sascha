'use strict'

const Bookshelf = require('../commons/bookshelf');
const Incidencia = require('../models/incidencia');

const Incidencias = Bookshelf.Collection.extend({
	model: Incidencia
});

module.exports = Incidencias;
