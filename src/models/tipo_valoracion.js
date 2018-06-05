'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./valoracion');

let TipoValoracion = Bookshelf.Model.extend({
  tableName: 'tipo_valoracion',
  idAttribute: 'id_tipo_valoracion',
  valoraciones: function() {
    return this.hasMany('Valoracion', 'id_tipo_valoracion')
      .query(function(qb) {
        qb.where('valoracion.estatus', 1);
        qb.orderBy('valoracion.valor', 'ASC');
      });
    }
});

module.exports = Bookshelf.model('TipoValoracion', TipoValoracion);