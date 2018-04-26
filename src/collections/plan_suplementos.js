'use strict'

const Bookshelf   = require('../commons/bookshelf');
const PlanSuplemento     = require('../models/plan_suplemento');

const PlanSuplementos = Bookshelf.Collection.extend({
	model: PlanSuplemento
});

module.exports = PlanSuplementos;