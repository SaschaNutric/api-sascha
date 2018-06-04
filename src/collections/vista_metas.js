'use strict'

const Bookshelf = require('../commons/bookshelf');
const VistaMeta = require('../models/vista_meta');

const VistaMetas = Bookshelf.Collection.extend({
    model: VistaMeta
});

module.exports = VistaMetas