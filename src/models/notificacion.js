'use strict'

const Bookshelf = require('../commons/bookshelf');

let Notificacion = Bookshelf.Model.extend({
  tableName: 'notificacion',
  idAttribute: 'id_notificacion'
});

module.exports = Bookshelf.model('Notificacion', Notificacion);