'use strict'

const Bookshelf   = require('../commons/bookshelf');
const Usuario     = require('../models/usuario');

const Usuarios = Bookshelf.Collection.extend({
	model: Usuario
});

module.exports = Usuarios;