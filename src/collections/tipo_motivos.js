'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoMotivo     = require('../models/tipo_motivo');

const TipoMotivos = Bookshelf.Collection.extend({
	model: TipoMotivo
});

module.exports = TipoMotivos;