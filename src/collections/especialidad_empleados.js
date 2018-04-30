'use strict'

const Bookshelf = require('../commons/bookshelf');
const Especialidad_empleado = require('../models/especialidad_empleado');

const Especialidad_empleados = Bookshelf.Collection.extend({
	model: Especialidad_empleado
});

module.exports = Especialidad_empleados;
