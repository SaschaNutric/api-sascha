'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoOrden = Bookshelf.Model.extend({
  tableName: 'tipo_orden',
  idAttribute: 'id_tipo_orden'
});

module.exports = Bookshelf.model('TipoOrden', TipoOrden);