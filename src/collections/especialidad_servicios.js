'use strict'

const Bookshelf = require('../commons/bookshelf');
const Especialidad_servicio = require('../models/especialidad_servicio');

const Especialidad_servicios = Bookshelf.Collection.extend({
	model: Especialidad_servicio
});

module.exports = Especialidad_servicios;
