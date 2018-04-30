'use strict'

const Bookshelf = require('../commons/bookshelf');

let Estado_civil = Bookshelf.Model.extend({
  tableName: 'estado_civil',
  idAttribute: 'id_estado_civil'
});

module.exports = Bookshelf.model('Estado_civil', Estado_civil);
