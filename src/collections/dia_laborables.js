'use strict'

const Bookshelf = require('../commons/bookshelf');
const Dia_laborable = require('../models/dia_laborable');

const Dia_laborables = Bookshelf.Collection.extend({
	model: Dia_laborable
});

module.exports = Dia_laborables;
