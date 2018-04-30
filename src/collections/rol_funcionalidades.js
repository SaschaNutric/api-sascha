'use strict'

const Bookshelf = require('../commons/bookshelf');
const Rol_funcionalidad = require('../models/rol_funcionalidad');

const Rol_funcionalidades = Bookshelf.Collection.extend({
	model: Rol_funcionalidad
});

module.exports = Rol_funcionalidades;
