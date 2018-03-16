var express = require('express');
var usersCtrl = require('../controllers/users');
var auth= require('../middlewares/auth');

module.exports = (function () {

	var api = express.Router();
  
  api.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
  });
  
	api.get('/users', usersCtrl.getUsers);
  api.post('/users', usersCtrl.saveUser);
  api.post('/login', usersCtrl.singIn);
  api.get('/users/:id', usersCtrl.getUserById);
  api.put('/users/:id', usersCtrl.updateUser);
  api.delete('/users/:id', usersCtrl.deleteUser);
  	
  return api;

})();