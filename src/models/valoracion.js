'use strict'

const Bookshelf = require('../commons/bookshelf');

let Valoracion = Bookshelf.Model.extend({
  tableName: 'valoracion',
  idAttribute: 'id_valoracion'
});

module.exports = Bookshelf.model('Valoracion', Valoracion);
