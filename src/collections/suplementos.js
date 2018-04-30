'use strict'

const Bookshelf = require('../commons/bookshelf');
const Suplemento = require('../models/suplemento');

const Suplementos = Bookshelf.Collection.extend({
	model: Suplemento
});

module.exports = Suplementos;
