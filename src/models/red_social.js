'use strict'

const Bookshelf = require('../commons/bookshelf');

let Red_social = Bookshelf.Model.extend({
  tableName: 'red_social',
  idAttribute: 'id_red_social'
});

module.exports = Bookshelf.model('Red_social', Red_social);
