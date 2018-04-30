'use strict'

const Bookshelf = require('../commons/bookshelf');

let Regimen_ejercicio = Bookshelf.Model.extend({
  tableName: 'regimen_ejercicio',
  idAttribute: 'id_regimen_ejercicio'
});

module.exports = Bookshelf.model('Regimen_ejercicio', Regimen_ejercicio);
