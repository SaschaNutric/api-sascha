'use strict'

const Bookshelf = require('../commons/bookshelf');
const Horario_empleado = require('../models/horario_empleado');

const Horario_empleados = Bookshelf.Collection.extend({
	model: Horario_empleado
});

module.exports = Horario_empleados;
