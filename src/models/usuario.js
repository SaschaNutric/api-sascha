'use strict'

const Bookshelf = require('../commons/bookshelf');
const Rol = require('./rol');
const Empleado = require('./empleado')

let Usuario = Bookshelf.Model.extend({
	tableName: 'usuario',
	idAttribute: 'id_usuario',
	empleado: function(){
		return this.hasMany(Empleado, 'id_usuario')
		.query({ where: { 'empleado.estatus': 1 } });
	},
	rol: function() {
    return this.belongsTo(Rol, 'id_rol')
    			.query({ where: { 'rol.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Usuario', Usuario);
