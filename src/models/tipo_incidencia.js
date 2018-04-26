'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoIncidencia = Bookshelf.Model.extend({
  tableName: 'tipo_incidencia',
  idAttribute: 'id_tipo_incidencia'
});

module.exports = Bookshelf.model('TipoIncidencia', TipoIncidencia);