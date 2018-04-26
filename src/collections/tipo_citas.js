'use strict'

const Bookshelf   = require('../commons/bookshelf');
const TipoCita     = require('../models/tipo_cita');

const TipoCitas = Bookshelf.Collection.extend({
	model: TipoCita
});

module.exports = TipoCitas;