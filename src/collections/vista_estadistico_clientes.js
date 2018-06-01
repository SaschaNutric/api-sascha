'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaEstadisticoCliente = require('../models/vista_estadistico_cliente');

const VistaEstadisticoClientes = Bookshelf.Collection.extend({
    model: VistaEstadisticoCliente
});

module.exports = VistaEstadisticoClientes;