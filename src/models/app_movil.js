'use strict'

const Bookshelf = require('../commons/bookshelf');

let App_movil = Bookshelf.Model.extend({
  tableName: 'app_movil',
  idAttribute: 'id_app_movil'
});

module.exports = Bookshelf.model('App_movil', App_movil);
