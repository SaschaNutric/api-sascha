'use strict'

const Bookshelf = require('../commons/bookshelf');
const Rol = require('./rol');

let Usuario = Bookshelf.Model.extend({
	tableName: 'usuario',
	idAttribute: 'id_usuario',
	rol: function() {
    return this.belongsTo(Rol, 'id_rol')
    			.query({ where: { 'rol.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Usuario', Usuario);
