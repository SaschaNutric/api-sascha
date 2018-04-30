'use strict'

const Bookshelf = require('../commons/bookshelf');
const Calificacion = require('../models/calificacion');

const Calificaciones = Bookshelf.Collection.extend({
	model: Calificacion
});

module.exports = Calificaciones;
