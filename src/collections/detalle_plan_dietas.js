'use strict'

const Bookshelf = require('../commons/bookshelf');
const Detalle_plan_dieta = require('../models/detalle_plan_dieta');

const Detalle_plan_dietas = Bookshelf.Collection.extend({
	model: Detalle_plan_dieta
});

module.exports = Detalle_plan_dietas;
