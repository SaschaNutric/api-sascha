'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro = require('./parametro');

let Parametro_promocion = Bookshelf.Model.extend({
  tableName: 'parametro_promocion',
  idAttribute: 'id_parametro_promocion',
  parametro: function() {
    return this.belongsTo(Parametro, 'id_parametro')
    			.query({ where: { 'parametro.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Parametro_promocion', Parametro_promocion);
