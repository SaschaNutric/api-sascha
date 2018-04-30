'use strict'

const Bookshelf = require('../commons/bookshelf');
const Reclamo = require('../models/reclamo');

const Reclamos = Bookshelf.Collection.extend({
	model: Reclamo
});

module.exports = Reclamos;
