'use strict'

const Bookshelf = require('../commons/bookshelf');
const Valoracion = require('../models/valoracion');

const Valoraciones = Bookshelf.Collection.extend({
	model: Valoracion
});

module.exports = Valoraciones;
