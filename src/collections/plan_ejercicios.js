'use strict'

const Bookshelf   = require('../commons/bookshelf');
const PlanEjercicio     = require('../models/plan_ejercicio');

const PlanEjercicios = Bookshelf.Collection.extend({
	model: PlanEjercicio
});

module.exports = PlanEjercicios;