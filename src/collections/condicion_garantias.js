'use strict'

const Bookshelf = require('../commons/bookshelf');
const Condicion_garantia = require('../models/condicion_garantia');

const Condicion_garantias = Bookshelf.Collection.extend({
	model: Condicion_garantia
});

module.exports = Condicion_garantias;
