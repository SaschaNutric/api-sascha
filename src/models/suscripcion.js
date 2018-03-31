'use strict'

const Bookshelf = require('../commons/bookshelf');

let Suscripcion = Bookshelf.Model.extend({
	tableName: 'suscripcion',
	idAttribute: 'id_suscripcion',

});

module.exports = Bookshelf.model('Suscripcion', Suscripcion);