'use strict'

const Bookshelf = require('../commons/bookshelf');
const Criterio = require('../models/criterio');

const Criterios = Bookshelf.Collection.extend({
	model: Criterio
});

module.exports = Criterios;
