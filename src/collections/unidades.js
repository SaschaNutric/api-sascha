'use strict'

const Bookshelf   = require('../commons/bookshelf');
const Unidad     = require('../models/unidad');

const Unidades = Bookshelf.Collection.extend({
	model: Unidad
});

module.exports = Unidades;