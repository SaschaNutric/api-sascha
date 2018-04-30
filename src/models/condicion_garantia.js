'use strict'

const Bookshelf = require('../commons/bookshelf');

let Condicion_garantia = Bookshelf.Model.extend({
  tableName: 'condicion_garantia',
  idAttribute: 'id_condicion_garantia'
});

module.exports = Bookshelf.model('Condicion_garantia', Condicion_garantia);
