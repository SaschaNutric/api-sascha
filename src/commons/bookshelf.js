var configDB = require('../../knexfile');
var Knex = require('knex')(configDB);
var Bookshelf = require('bookshelf')(Knex);

module.exports = Bookshelf;