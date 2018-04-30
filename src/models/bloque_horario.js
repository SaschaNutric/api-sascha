'use strict'

const Bookshelf = require('../commons/bookshelf');

let Bloque_horario = Bookshelf.Model.extend({
  tableName: 'bloque_horario',
  idAttribute: 'id_bloque_horario'
});

module.exports = Bookshelf.model('Bloque_horario', Bloque_horario);
