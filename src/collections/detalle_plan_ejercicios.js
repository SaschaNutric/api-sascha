'use strict'

const Bookshelf = require('../commons/bookshelf');
const Detalle_plan_ejercicio = require('../models/detalle_plan_ejercicio');

const Detalle_plan_ejercicios = Bookshelf.Collection.extend({
	model: Detalle_plan_ejercicio
});

module.exports = Detalle_plan_ejercicios;
