'use strict'

const Bookshelf = require('../commons/bookshelf');

let TipoCita = Bookshelf.Model.extend({
  tableName: 'tipo_cita',
  idAttribute: 'id_tipo_cita'
});

module.exports = Bookshelf.model('TipoCita', TipoCita);