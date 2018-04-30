'use strict'

const Bookshelf = require('../commons/bookshelf');

let Motivo = Bookshelf.Model.extend({
  tableName: 'motivo',
  idAttribute: 'id_motivo'
});

module.exports = Bookshelf.model('Motivo', Motivo);
