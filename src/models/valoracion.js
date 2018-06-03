'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoValoracion = require('./tipo_valoracion');
require('./tipo_valoracion');

let Valoracion = Bookshelf.Model.extend({
  tableName: 'valoracion',
  idAttribute: 'id_valoracion',
    tipo_valoracion: function() {
    return this.belongsTo('TipoValoracion', 'id_tipo_valoracion')
    			.query({ where: { 'tipo_valoracion.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Valoracion', Valoracion);
