'use strict'

const Bookshelf   = require('../commons/bookshelf');
const PlanDieta     = require('../models/plan_dieta');

const PlanDietas = Bookshelf.Collection.extend({
	model: PlanDieta
});

module.exports = PlanDietas;