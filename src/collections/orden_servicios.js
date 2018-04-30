'use strict'

const Bookshelf = require('../commons/bookshelf');
const Orden_servicio = require('../models/orden_servicio');

const Orden_servicios = Bookshelf.Collection.extend({
	model: Orden_servicio
});

module.exports = Orden_servicios;
