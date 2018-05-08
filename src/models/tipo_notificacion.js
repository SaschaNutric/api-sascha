'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoNotificacion = Bookshelf.Model.extend({
  tableName: 'tipo_notificacion',
  idAttribute: 'id_tipo_notificacion'
});

module.exports = Bookshelf.model('TipoNotificacion', TipoNotificacion);