'use strict'

const Bookshelf = require('../commons/bookshelf');
const Motivo = require('../models/motivo');

const Motivos = Bookshelf.Collection.extend({
	model: Motivo
});

module.exports = Motivos;
