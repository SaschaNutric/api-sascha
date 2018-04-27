'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoValoracion     = require('../models/tipo_valoracion');

const TipoValoraciones = Bookshelf.Collection.extend({
	model: TipoValoracion
});

module.exports = TipoValoraciones;