'use strict'

const Bookshelf = require('../commons/bookshelf');
const Tipo_comentario = require('../models/tipo_comentario');

const Tipo_comentarios = Bookshelf.Collection.extend({
	model: Tipo_comentario
});

module.exports = Tipo_comentarios;
