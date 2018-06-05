'use strict'

const Bookshelf = require('../commons/bookshelf');
const ParametroMeta = require('../models/parametro_meta');

const ParametrosMetas = Bookshelf.Collection.extend({
    model: ParametroMeta
});

module.exports = ParametrosMetas;