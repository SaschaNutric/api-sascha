'use strict'

const Bookshelf   = require('../commons/bookshelf');
const Negocio     = require('../models/negocio');

const Negocios = Bookshelf.Collection.extend({
	model: Negocio
});

module.exports = Negocios;