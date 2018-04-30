'use strict'

const Bookshelf = require('../commons/bookshelf');

let Cita = Bookshelf.Model.extend({
  tableName: 'cita',
  idAttribute: 'id_cita'
});

module.exports = Bookshelf.model('Cita', Cita);
