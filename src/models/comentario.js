'use strict'

const Bookshelf = require('../commons/bookshelf');
const Cliente = require('./cliente'); 
const Respuesta = require('./respuesta'); 
const Motivo = require('./motivo'); 

let Comentario = Bookshelf.Model.extend({
  tableName: 'comentario',
  idAttribute: 'id_comentario',
  cliente: function() { 
    return this.belongsTo( Cliente, 'id_cliente' )
          .query({ where: { 'cliente.estatus': 1 } }); 
  },
  respuesta: function() { 
    return this.belongsTo( Respuesta, 'id_respuesta' )
          .query({ where: { 'respuesta.estatus': 1 } }); 
  },
  motivo: function() { 
    return this.belongsTo( Motivo, 'id_motivo' )
          .query({ where: { 'motivo.estatus': 1 } }); 
  }
});

module.exports = Bookshelf.model('Comentario', Comentario);
