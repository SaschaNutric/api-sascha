'use strict'

const Bookshelf = require('../commons/bookshelf');
const Cliente = require('./cliente'); 
const Respuesta = require('./respuesta'); 
const Tipo_comentario = require('./tipo_comentario'); 

let Comentario = Bookshelf.Model.extend({
  tableName: 'comentario',
  idAttribute: 'id_comentario',
  cliente: function() { 
  	return this.belongsTo( Cliente, 'id_cliente' ); 
  },
  respuesta: function() { 
  	return this.belongsTo( Respuesta, 'id_respuesta' ); 
  },
  tipo_comentario: function() { 
  	return this.belongsTo( Tipo_comentario, 'id_tipo_comentario' ); 
  }
});

module.exports = Bookshelf.model('Comentario', Comentario);
