'use strict'

const Bookshelf = require('../commons/bookshelf');
const RolFuncionalidad = require('./rol_funcionalidad')

let Rol = Bookshelf.Model.extend({
  tableName: 'rol',
  idAttribute: 'id_rol',
  funcionalidades: function () {
    return this.hasMany(RolFuncionalidad, 'id_rol')
      .query({ where: { 'rol_funcionalidad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Rol', Rol);
