'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./unidad');

let TipoUnidad = Bookshelf.Model.extend({
  tableName: 'tipo_unidad',
  idAttribute: 'id_tipo_unidad',
  unidades: function() {
  	return this.hasMany('Unidad', 'id_tipo_unidad')
    .query({ where: { 'unidad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('TipoUnidad', TipoUnidad);