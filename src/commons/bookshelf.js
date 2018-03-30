var configDB = require('../../knexfile')['development'];
var Knex = require('knex')(configDB);
var Bookshelf = require('bookshelf')(Knex);

module.exports = Bookshelf;