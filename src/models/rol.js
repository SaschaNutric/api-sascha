'use strict'

const Bookshelf = require('../commons/bookshelf');

let Rol = Bookshelf.Model.extend({
  tableName: 'rol',
  idAttribute: 'id_rol'
});

module.exports = Bookshelf.model('Rol', Rol);
