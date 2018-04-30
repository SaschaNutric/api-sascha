'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro_servicio = require('../models/parametro_servicio');

const Parametro_servicios = Bookshelf.Collection.extend({
	model: Parametro_servicio
});

module.exports = Parametro_servicios;
