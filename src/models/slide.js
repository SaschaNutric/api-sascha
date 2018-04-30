'use strict'

const Bookshelf = require('../commons/bookshelf');

let Slide = Bookshelf.Model.extend({
  tableName: 'slide',
  idAttribute: 'id_slide'
});

module.exports = Bookshelf.model('Slide', Slide);
