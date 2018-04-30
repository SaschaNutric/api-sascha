'use strict'

const Bookshelf = require('../commons/bookshelf');

let Ejercicio = Bookshelf.Model.extend({
  tableName: 'ejercicio',
  idAttribute: 'id_ejercicio'
});

module.exports = Bookshelf.model('Ejercicio', Ejercicio);
