'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoDieta     = require('../models/tipo_dieta');

const TipoDietas = Bookshelf.Collection.extend({
	model: TipoDieta
});

module.exports = TipoDietas;