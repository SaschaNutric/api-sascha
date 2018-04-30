'use strict'

const Bookshelf = require('../commons/bookshelf');
const Detalle_regimen_alimento = require('../models/detalle_regimen_alimento');

const Detalle_regimen_alimentos = Bookshelf.Collection.extend({
	model: Detalle_regimen_alimento
});

module.exports = Detalle_regimen_alimentos;
