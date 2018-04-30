'use strict'

const Bookshelf = require('../commons/bookshelf');
const Cita = require('../models/cita');

const Citas = Bookshelf.Collection.extend({
	model: Cita
});

module.exports = Citas;
