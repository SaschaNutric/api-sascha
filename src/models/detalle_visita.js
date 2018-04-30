'use strict'

const Bookshelf = require('../commons/bookshelf');

let Detalle_visita = Bookshelf.Model.extend({
  tableName: 'detalle_visita',
  idAttribute: 'id_detalle_visita'
});

module.exports = Bookshelf.model('Detalle_visita', Detalle_visita);
