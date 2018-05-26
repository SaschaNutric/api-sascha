'use strict'

const Bookshelf = require('../commons/bookshelf');
require('./funcionalidad')

let Rol = Bookshelf.Model.extend({
  tableName: 'rol',
  idAttribute: 'id_rol',
  funcionalidades: function () {
    return this.hasMany('Funcionalidad', 'id_funcionalidad')
      .query({ where: { 'funcionalidad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Rol', Rol);
