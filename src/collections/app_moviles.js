'use strict'

const Bookshelf = require('../commons/bookshelf');
const App_movil = require('../models/app_movil');

const App_moviles = Bookshelf.Collection.extend({
	model: App_movil
});

module.exports = App_moviles;
