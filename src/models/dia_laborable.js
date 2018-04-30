'use strict'

const Bookshelf = require('../commons/bookshelf');

let Dia_laborable = Bookshelf.Model.extend({
  tableName: 'dia_laborable',
  idAttribute: 'id_dia_laborable'
});

module.exports = Bookshelf.model('Dia_laborable', Dia_laborable);
