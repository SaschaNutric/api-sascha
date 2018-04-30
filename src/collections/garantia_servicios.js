'use strict'

const Bookshelf = require('../commons/bookshelf');
const Garantia_servicio = require('../models/garantia_servicio');

const Garantia_servicios = Bookshelf.Collection.extend({
	model: Garantia_servicio
});

module.exports = Garantia_servicios;
