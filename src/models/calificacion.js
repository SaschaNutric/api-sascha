'use strict'

const Bookshelf = require('../commons/bookshelf');

let Calificacion = Bookshelf.Model.extend({
  tableName: 'calificacion',
  idAttribute: 'id_calificacion'
});

module.exports = Bookshelf.model('Calificacion', Calificacion);
