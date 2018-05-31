'use strict'

const Bookshelf = require('../commons/bookshelf');
const Funcionalidad = require('./funcionalidad')
const Usuario = require('./usuario')


let Rol = Bookshelf.Model.extend({
  tableName: 'rol',
  idAttribute: 'id_rol',
  usuario: function (){
    return this.hasMany(Usuario, 'id_rol')
    .query({where : {'usuario.estatus': 1}});
  },
  funcionalidades: function () {
    return this.belongsToMany(Funcionalidad, 'rol_funcionalidad','id_rol', 'id_funcionalidad')
      .query({ where: { 'funcionalidad.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Rol', Rol);
