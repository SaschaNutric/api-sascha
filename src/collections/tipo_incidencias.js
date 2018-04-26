'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoIncidencia     = require('../models/tipo_incidencia');

const TipoIncidencias = Bookshelf.Collection.extend({
	model: TipoIncidencia
});

module.exports = TipoIncidencias;