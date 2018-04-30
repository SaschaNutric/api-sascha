'use strict'

const Bookshelf = require('../commons/bookshelf');
const Estado = require('../models/estado');

const Estados = Bookshelf.Collection.extend({
	model: Estado
});

module.exports = Estados;
