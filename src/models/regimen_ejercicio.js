'use strict'

const Bookshelf = require('../commons/bookshelf');
const Ejercicio = require('./ejercicio');

let Regimen_ejercicio = Bookshelf.Model.extend({
  tableName: 'regimen_ejercicio',
  idAttribute: 'id_regimen_ejercicio',
  ejercicio: function () {
    return this.belongsTo(Ejercicio, 'id_ejercicio');
  }
});

module.exports = Bookshelf.model('Regimen_ejercicio', Regimen_ejercicio);
