'use strict'

const Bookshelf = require('../commons/bookshelf');
const Grupo_alimenticio = require('../models/grupo_alimenticio');

const Grupo_alimenticios = Bookshelf.Collection.extend({
	model: Grupo_alimenticio
});

module.exports = Grupo_alimenticios;
