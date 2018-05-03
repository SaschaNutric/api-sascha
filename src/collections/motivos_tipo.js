'use strict'

const Bookshelf = require('../commons/bookshelf');
const Motivo = require('../models/motivo');

const Motivos_tipo = Bookshelf.Collection.extend({
	model: Motivo
});

module.exports = Motivos_tipo;