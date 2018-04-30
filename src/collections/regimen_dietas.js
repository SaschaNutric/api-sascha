'use strict'

const Bookshelf = require('../commons/bookshelf');
const Regimen_dieta = require('../models/regimen_dieta');

const Regimen_dietas = Bookshelf.Collection.extend({
	model: Regimen_dieta
});

module.exports = Regimen_dietas;
