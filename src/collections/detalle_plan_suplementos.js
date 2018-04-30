'use strict'

const Bookshelf = require('../commons/bookshelf');
const Detalle_plan_suplemento = require('../models/detalle_plan_suplemento');

const Detalle_plan_suplementos = Bookshelf.Collection.extend({
	model: Detalle_plan_suplemento
});

module.exports = Detalle_plan_suplementos;
