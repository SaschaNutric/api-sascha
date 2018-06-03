'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaCanalEscucha = require('../models/vista_canal_escucha');

const VistaCanalEscuchas = Bookshelf.Collection.extend({
    model: VistaCanalEscucha
});

module.exports = VistaCanalEscuchas;