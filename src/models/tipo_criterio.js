'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoValoracion  	= require('./tipo_valoracion');
require('./criterio');

let TipoCriterio = Bookshelf.Model.extend({
  tableName: 'tipo_criterio',
  idAttribute: 'id_tipo_criterio',  
  criterios: function() {
    return this.hasMany('Criterio', 'id_tipo_criterio')
    	.query({ where: { 'criterio.estatus': 1 } });
  },
  tipo_valoracion: function() {
    return this.belongsTo(TipoValoracion, 'id_tipo_valoracion')
    	.query({ where: { 'tipo_valoracion.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('TipoCriterio', TipoCriterio);