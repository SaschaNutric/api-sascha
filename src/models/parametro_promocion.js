'use strict'

const Bookshelf = require('../commons/bookshelf');

let Parametro_promocion = Bookshelf.Model.extend({
  tableName: 'parametro_promocion',
  idAttribute: 'id_parametro_promocion'
});

module.exports = Bookshelf.model('Parametro_promocion', Parametro_promocion);
