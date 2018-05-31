'use strict'

const Bookshelf = require('../commons/bookshelf');
const TipoCriterio  	= require('./tipo_criterio');

let Criterio = Bookshelf.Model.extend({
  tableName: 'criterio',
  idAttribute: 'id_criterio',
  tipo_criterio: function() {
    return this.belongsTo(TipoCriterio, 'id_tipo_criterio')
    	.query({ where: { 'tipo_criterio.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Criterio', Criterio);
