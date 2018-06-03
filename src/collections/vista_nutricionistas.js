'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaNutricionista = require('../models/vista_nutricionista');

const VistaNutricionistas = Bookshelf.Collection.extend({
    model: VistaNutricionista
});

module.exports = VistaNutricionistas;