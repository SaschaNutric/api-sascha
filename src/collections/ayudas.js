'use strict'

const Bookshelf = require('../commons/bookshelf');
const Ayuda = require('../models/ayuda');

const Ayudas = Bookshelf.Collection.extend({
	model: Ayuda
});

module.exports = Ayudas;
