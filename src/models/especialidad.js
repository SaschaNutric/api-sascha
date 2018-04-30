'use strict'

const Bookshelf = require('../commons/bookshelf');

let Especialidad = Bookshelf.Model.extend({
  tableName: 'especialidad',
  idAttribute: 'id_especialidad'
});

module.exports = Bookshelf.model('Especialidad', Especialidad);
