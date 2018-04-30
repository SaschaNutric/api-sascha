'use strict'

const Bookshelf = require('../commons/bookshelf');
const Empleado = require('../models/empleado');

const Empleados = Bookshelf.Collection.extend({
	model: Empleado
});

module.exports = Empleados;
