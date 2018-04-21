'use strict'

const Bookshelf = require('../commons/bookshelf');

let EstadoCivil = Bookshelf.Model.extend({
	tableName: 'estado_civil',
	idAttribute: 'id_estado_civil',
});

module.exports = Bookshelf.model('EstadoCivil', EstadoCivil);