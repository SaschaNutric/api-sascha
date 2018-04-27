'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoUnidad     = require('../models/tipo_unidad');

const TipoUnidades = Bookshelf.Collection.extend({
	model: TipoUnidad
});

module.exports = TipoUnidades;