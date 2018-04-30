'use strict'

const Bookshelf = require('../commons/bookshelf');
const Red_social = require('../models/red_social');

const Red_sociales = Bookshelf.Collection.extend({
	model: Red_social
});

module.exports = Red_sociales;
