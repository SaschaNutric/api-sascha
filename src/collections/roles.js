'use strict'

const Bookshelf = require('../commons/bookshelf');
const Rol = require('../models/rol');

const Roles = Bookshelf.Collection.extend({
	model: Rol
});

module.exports = Roles;
