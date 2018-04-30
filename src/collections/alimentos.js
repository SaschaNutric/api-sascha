'use strict'

const Bookshelf = require('../commons/bookshelf');
const Alimento = require('../models/alimento');

const Alimentos = Bookshelf.Collection.extend({
	model: Alimento
});

module.exports = Alimentos;
