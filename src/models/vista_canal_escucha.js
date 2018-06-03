'use strict'

const Bookshelf = require('../commons/bookshelf');

let VistaCanalEscucha = Bookshelf.Model.extend({
    tableName: 'vista_canal_escucha',
    idAttribute: 'id_comentario',
});

module.exports = Bookshelf.model('VistaCanalEscucha', VistaCanalEscucha);