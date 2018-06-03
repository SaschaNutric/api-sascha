'use strict'

const Bookshelf = require('../commons/bookshelf');

let VistaNutricionista = Bookshelf.Model.extend({
    tableName: 'vista_nutricionista',
    idAttribute: 'id_agenda',
});

module.exports = Bookshelf.model('VistaNutricionista', VistaNutricionista);