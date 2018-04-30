'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoCriterio  	= require('./tipo_criterio');
const TipoValoracion  	= require('./tipo_valoracion');

let Criterio = Bookshelf.Model.extend({
  tableName: 'criterio',
  idAttribute: 'id_criterio',
  tipo_criterio: function() {
    return this.belongsTo(TipoCriterio, 'id_tipo_criterio');
  },  
  tipo_valoracion: function() {
    return this.belongsTo(TipoValoracion, 'id_tipo_valoracion');
  }
});

module.exports = Bookshelf.model('Criterio', Criterio);
