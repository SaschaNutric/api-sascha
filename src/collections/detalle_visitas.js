'use strict'

const Bookshelf = require('../commons/bookshelf');
const Detalle_visita = require('../models/detalle_visita');

const Detalle_visitas = Bookshelf.Collection.extend({
	model: Detalle_visita
});

module.exports = Detalle_visitas;
