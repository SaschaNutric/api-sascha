'use strict'

const Bookshelf = require('../commons/bookshelf');

let VistaAgenda = Bookshelf.Model.extend({
    tableName: 'vista_agenda',
    idAttribute: 'id_agenda'
});

module.exports = Bookshelf.model('VistaAgenda', VistaAgenda);