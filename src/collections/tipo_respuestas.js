'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoRespuesta     = require('../models/tipo_respuesta');

const TipoRespuestas = Bookshelf.Collection.extend({
	model: TipoRespuesta
});

module.exports = TipoRespuestas;