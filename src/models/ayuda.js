'use strict'

const Bookshelf = require('../commons/bookshelf');

let Ayuda = Bookshelf.Model.extend({
  tableName: 'ayuda',
  idAttribute: 'id_ayuda'
});

module.exports = Bookshelf.model('Ayuda', Ayuda);
