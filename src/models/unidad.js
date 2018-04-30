'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoUnidad = require('./tipo_unidad');

let Unidad = Bookshelf.Model.extend({
  tableName: 'unidad',
  idAttribute: 'id_unidad',
  tipo_unidad: function() {
    return this.belongsTo(TipoUnidad, 'id_tipo_unidad');
  }
});

module.exports = Bookshelf.model('Unidad', Unidad);