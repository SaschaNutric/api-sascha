'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro_promocion = require('../models/parametro_promocion');

const Parametro_promociones = Bookshelf.Collection.extend({
	model: Parametro_promocion
});

module.exports = Parametro_promociones;
