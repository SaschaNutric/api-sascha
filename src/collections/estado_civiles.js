'use strict'

const Bookshelf = require('../commons/bookshelf');
const Estado_civil = require('../models/estado_civil');

const Estado_civiles = Bookshelf.Collection.extend({
	model: Estado_civil
});

module.exports = Estado_civiles;
