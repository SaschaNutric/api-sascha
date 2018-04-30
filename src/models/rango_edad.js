'use strict'

const Bookshelf = require('../commons/bookshelf');

let Rango_edad = Bookshelf.Model.extend({
  tableName: 'rango_edad',
  idAttribute: 'id_rango_edad'
});

module.exports = Bookshelf.model('Rango_edad', Rango_edad);
