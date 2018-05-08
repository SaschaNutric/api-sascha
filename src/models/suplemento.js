'use strict'

const Bookshelf = require('../commons/bookshelf');
<<<<<<< HEAD
const Unidad = require('./unidad');
=======
const Unidad    = require('./unidad');
>>>>>>> 129974c6e304539abb7a7704987c9bd15e68db3f

let Suplemento = Bookshelf.Model.extend({
  tableName: 'suplemento',
  idAttribute: 'id_suplemento',
  unidad: function() {
    return this.belongsTo(Unidad, 'id_unidad');
  }
});

module.exports = Bookshelf.model('Suplemento', Suplemento);
