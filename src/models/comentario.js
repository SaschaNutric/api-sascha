'use strict'

const Bookshelf = require('../commons/bookshelf');
const Cliente = require('./cliente'); 
const Respuesta = require('./respuesta'); 
const Motivo = require('./motivo'); 

let Comentario = Bookshelf.Model.extend({
  tableName: 'comentario',
  idAttribute: 'id_comentario',
  cliente: function() { 
    return this.belongsTo( Cliente, 'id_cliente' ); 
  },
  respuesta: function() { 
    return this.belongsTo( Respuesta, 'id_respuesta' ); 
  },motivo: function() { 
    return this.belongsTo( Motivo, 'id_motivo' ); 
  }
});

module.exports = Bookshelf.model('Comentario', Comentario);
