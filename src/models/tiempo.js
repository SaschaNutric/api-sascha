'use strict'

const Bookshelf = require('../commons/bookshelf');

let Tiempo = Bookshelf.Model.extend({
  tableName: 'tiempo',
  idAttribute: 'id_tiempo'
});

module.exports = Bookshelf.model('Tiempo', Tiempo);
