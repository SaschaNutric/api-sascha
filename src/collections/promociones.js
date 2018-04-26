'use strict'

const Bookshelf   = require('../commons/bookshelf');
const Promocion     = require('../models/promocion');

const Promociones = Bookshelf.Collection.extend({
	model: Promocion
});

module.exports = Promociones;