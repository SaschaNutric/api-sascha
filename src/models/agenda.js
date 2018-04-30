'use strict'

const Bookshelf = require('../commons/bookshelf');

let Agenda = Bookshelf.Model.extend({
  tableName: 'agenda',
  idAttribute: 'id_agenda'
});

module.exports = Bookshelf.model('Agenda', Agenda);
