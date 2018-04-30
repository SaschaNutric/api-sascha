'use strict'

const Bookshelf = require('../commons/bookshelf');
const Solicitud_servicio = require('../models/solicitud_servicio');

const Solicitud_servicios = Bookshelf.Collection.extend({
	model: Solicitud_servicio
});

module.exports = Solicitud_servicios;
