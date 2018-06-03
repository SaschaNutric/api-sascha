'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaReclamo = require('../models/vista_reclamo');

const VistaReclamos = Bookshelf.Collection.extend({
    model: VistaReclamo
});

module.exports = VistaReclamos;