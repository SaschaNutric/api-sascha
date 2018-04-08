const NODE_ENV = process.env.NODE_ENV || 'development';
var configDB = require('../../knexfile')[NODE_ENV];
var Knex = require('knex')(configDB);
var Bookshelf = require('bookshelf')(Knex);
Bookshelf.plugin('registry');
module.exports = Bookshelf;