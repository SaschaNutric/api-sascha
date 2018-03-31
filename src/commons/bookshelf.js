var configDB = require('../../knexfile')['development'];
var Knex = require('knex')(configDB);
var Bookshelf = require('bookshelf')(Knex);
Bookshelf.plugin('registry');
module.exports = Bookshelf;