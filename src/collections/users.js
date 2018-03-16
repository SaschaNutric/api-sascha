var Bookshelf = require('../commons/bookshelf');
var User = require('../models/user');

var Users = Bookshelf.Collection.extend({
	model : User
});
module.exports = Users;