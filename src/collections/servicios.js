'use strict'

const Bookshelf   = require('../commons/bookshelf');
const Servicio     = require('../models/servicio');

const Servicios = Bookshelf.Collection.extend({
	model: Servicio
});

module.exports = Servicios;