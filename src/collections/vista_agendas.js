'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaAgenda = require('../models/vista_agenda');

const VistaAgendas = Bookshelf.Collection.extend({
    model: VistaAgenda
});

module.exports = VistaAgendas;