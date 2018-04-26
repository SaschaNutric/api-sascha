'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoParametro     = require('../models/tipo_parametro');

const TipoParametros = Bookshelf.Collection.extend({
	model: TipoParametro
});

module.exports = TipoParametros;