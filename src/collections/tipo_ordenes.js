'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoOrden     = require('../models/tipo_orden');

const TipoOrdenes = Bookshelf.Collection.extend({
	model: TipoOrden
});

module.exports = TipoOrdenes;