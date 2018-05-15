'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro = require('./parametro');

let Parametro_promocion = Bookshelf.Model.extend({
  tableName: 'parametro_promocion',
  idAttribute: 'id_parametro_promocion',
  parametro: function() {
    return this.hasOne(Parametro, 'id_parametro');
  }
});

module.exports = Bookshelf.model('Parametro_promocion', Parametro_promocion);
