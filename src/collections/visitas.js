'use strict'

const Bookshelf = require('../commons/bookshelf');
const Visita = require('../models/visita');

const Visitas = Bookshelf.Collection.extend({
	model: Visita
});

module.exports = Visitas;
