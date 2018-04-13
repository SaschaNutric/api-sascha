'use strict'

const Bookshelf   = require('../commons/bookshelf');
const EstadoCivil     = require('../models/estado_civil');

const EstadosCivil = Bookshelf.Collection.extend({
	model: EstadoCivil
});

module.exports = EstadosCivil;