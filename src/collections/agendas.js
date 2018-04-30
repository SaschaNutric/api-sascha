'use strict'

const Bookshelf = require('../commons/bookshelf');
const Agenda = require('../models/agenda');

const Agendas = Bookshelf.Collection.extend({
	model: Agenda
});

module.exports = Agendas;
