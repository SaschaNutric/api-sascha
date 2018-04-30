'use strict'

const Bookshelf = require('../commons/bookshelf');
const Comentario = require('../models/comentario');

const Comentarios = Bookshelf.Collection.extend({
	model: Comentario
});

module.exports = Comentarios;
