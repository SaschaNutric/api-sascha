'use strict'

const Bookshelf = require('../commons/bookshelf');

let VistaMeta = Bookshelf.Model.extend({
	tableName: 'vista_metas',
	idAttribute: 'id_parametro_meta',
});

module.exports = Bookshelf.model('VistaMeta', VistaMeta);