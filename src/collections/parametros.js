'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro = require('../models/parametro');

const Parametros = Bookshelf.Collection.extend({
	model: Parametro
});

module.exports = Parametros;
