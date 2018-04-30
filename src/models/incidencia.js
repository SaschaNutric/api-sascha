'use strict'

const Bookshelf = require('../commons/bookshelf');

let Incidencia = Bookshelf.Model.extend({
  tableName: 'incidencia',
  idAttribute: 'id_incidencia'
});

module.exports = Bookshelf.model('Incidencia', Incidencia);
