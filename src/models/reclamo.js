'use strict'

const Bookshelf = require('../commons/bookshelf');

let Reclamo = Bookshelf.Model.extend({
  tableName: 'reclamo',
  idAttribute: 'id_reclamo'
});

module.exports = Bookshelf.model('Reclamo', Reclamo);
