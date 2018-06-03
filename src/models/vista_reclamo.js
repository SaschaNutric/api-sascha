'use strict'

const Bookshelf = require('../commons/bookshelf');

let VistaReclamo = Bookshelf.Model.extend({
    tableName: 'vista_reclamo',
    idAttribute: 'id_reclamo',
});

module.exports = Bookshelf.model('VistaReclamo', VistaReclamo);