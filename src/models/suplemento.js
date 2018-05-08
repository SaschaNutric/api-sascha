'use strict'

const Bookshelf = require('../commons/bookshelf');
const Unidad    = require('./unidad');

let Suplemento = Bookshelf.Model.extend({
  tableName: 'suplemento',
  idAttribute: 'id_suplemento',
  unidad: function() {
    return this.belongsTo(Unidad, 'id_unidad');
  }
});

module.exports = Bookshelf.model('Suplemento', Suplemento);
