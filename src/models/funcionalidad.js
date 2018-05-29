'use strict'

const Bookshelf = require('../commons/bookshelf');

let Funcionalidad = Bookshelf.Model.extend({
  tableName: 'funcionalidad',
  idAttribute: 'id_funcionalidad',
  hijos: function(){
    return this.hasMany(Funcionalidad, 'id_funcionalidad_padre', 'id_funcionalidad')
    .query({ where: { 'funcionalidad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Funcionalidad', Funcionalidad);
