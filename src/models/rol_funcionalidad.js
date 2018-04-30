'use strict'

const Bookshelf = require('../commons/bookshelf');

let Rol_funcionalidad = Bookshelf.Model.extend({
  tableName: 'rol_funcionalidad',
  idAttribute: 'id_rol_funcionalidad'
});

module.exports = Bookshelf.model('Rol_funcionalidad', Rol_funcionalidad);
