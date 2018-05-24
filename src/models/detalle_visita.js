'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro = require('./parametro');

let Detalle_visita = Bookshelf.Model.extend({
  tableName: 'detalle_visita',
  idAttribute: 'id_detalle_visita',
  parametro: function() {
    return this.belongsTo(Parametro, 'id_parametro')
               .query({ where: { estatus: 1 } })
  }
});

module.exports = Bookshelf.model('Detalle_visita', Detalle_visita);
