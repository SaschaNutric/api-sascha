'use strict'

const Bookshelf = require('../commons/bookshelf');
const Unidad    = require('./unidad');

let Precio = Bookshelf.Model.extend({
  tableName: 'precio',
  idAttribute: 'id_precio',
  unidad: function() {
    return this.belongsTo(Unidad, 'id_unidad');
  }
});

module.exports = Bookshelf.model('Precio', Precio);
