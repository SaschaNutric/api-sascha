'use strict'

const Bookshelf = require('../commons/bookshelf');

let Funcionalidad = Bookshelf.Model.extend({
  tableName: 'funcionalidad',
  idAttribute: 'id_funcionalidad'
});

module.exports = Bookshelf.model('Funcionalidad', Funcionalidad);
