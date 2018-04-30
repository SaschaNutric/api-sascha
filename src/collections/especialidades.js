'use strict'

const Bookshelf = require('../commons/bookshelf');
const Especialidad = require('../models/especialidad');

const Especialidades = Bookshelf.Collection.extend({
	model: Especialidad
});

module.exports = Especialidades;
