'use strict'

const Bookshelf  = require('../commons/bookshelf');
const Suplemento = require('./suplemento');
const Frecuencia = require('./frecuencia');

let Regimen_suplemento = Bookshelf.Model.extend({
  tableName: 'regimen_suplemento',
  idAttribute: 'id_regimen_suplemento',
  suplemento: function () {
    return this.belongsTo(Suplemento, 'id_suplemento')
    			.query({ where: { 'suplemento.estatus': 1 } });
  },
  frecuencia: function () {
    return this.belongsTo(Frecuencia, 'id_frecuencia')
    			.query({ where: { 'frecuencia.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Regimen_suplemento', Regimen_suplemento);
