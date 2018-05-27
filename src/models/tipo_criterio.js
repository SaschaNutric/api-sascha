'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoValoracion  	= require('./tipo_valoracion');

let TipoCriterio = Bookshelf.Model.extend({
  tableName: 'tipo_criterio',
  idAttribute: 'id_tipo_criterio',  
  tipo_valoracion: function() {
    return this.belongsTo(TipoValoracion, 'id_tipo_valoracion')
    	.query({ where: { 'tipo_valoracion.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('TipoCriterio', TipoCriterio);