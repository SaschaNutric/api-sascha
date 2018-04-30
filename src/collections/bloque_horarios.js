'use strict'

const Bookshelf = require('../commons/bookshelf');
const Bloque_horario = require('../models/bloque_horario');

const Bloque_horarios = Bookshelf.Collection.extend({
	model: Bloque_horario
});

module.exports = Bloque_horarios;
