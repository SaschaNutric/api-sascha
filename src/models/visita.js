'use strict'

const Bookshelf = require('../commons/bookshelf');

let Visita = Bookshelf.Model.extend({
  tableName: 'visita',
  idAttribute: 'id_visita'
});

module.exports = Bookshelf.model('Visita', Visita);
