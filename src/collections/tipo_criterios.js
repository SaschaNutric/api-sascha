'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoCriterio     = require('../models/tipo_criterio');

const TipoCriterios = Bookshelf.Collection.extend({
	model: TipoCriterio
});

module.exports = TipoCriterios;