var express = require('express');
var usersCtrl = require('../controllers/users');
var auth= require('../middlewares/auth');
var cors = require('cors');

module.exports = (function () {

	var api = express.Router();
  
  api.get('/', function(req, res, next) {
    res.status(200)
      .json({
        error : false,
        data : { message : 'api-sascha' }
      })
  });

	api.get('/users', auth, usersCtrl.getUsers);
  api.post('/users', usersCtrl.saveUser);
  api.post('/login', usersCtrl.singIn);
  api.get('/users/:id', usersCtrl.getUserById);
  api.put('/users/:id', usersCtrl.updateUser);
  api.delete('/users/:id', usersCtrl.deleteUser);
  	
  return api;

})();