'use strict'

const Bookshelf = require('../commons/bookshelf');
const Regimen_suplemento = require('../models/regimen_suplemento');

const Regimen_suplementos = Bookshelf.Collection.extend({
	model: Regimen_suplemento
});

module.exports = Regimen_suplementos;
