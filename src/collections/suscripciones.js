'use strict'

const Bookshelf   = require('../commons/bookshelf');
const Suscripcion = require('../models/suscripcion');

const Suscripciones = Bookshelf.Collection.extend({
	model : Suscripcion
});

module.exports = Suscripciones;