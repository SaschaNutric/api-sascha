'use strict'

const Bookshelf = require('../commons/bookshelf');
const Funcionalidad = require('./funcionalidad');
const Rol = require('./rol')

let Rol_funcionalidad = Bookshelf.Model.extend({
  tableName: 'rol_funcionalidad',
  idAttribute: 'id_rol_funcionalidad',
  rol: function () {
    return this.belongsTo(Rol, 'id_rol')
    			.query({ where: { 'rol.estatus': 1 } });
  },
  funcionalidad: function () {
    return this.belongsTo(Funcionalidad, 'id_funcionalidad')
    			.query({ where: { 'funcionalidad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Rol_funcionalidad', Rol_funcionalidad);
