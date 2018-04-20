var express = require('express');
var usersCtrl = require('../controllers/users');
//const clientesCtrl = require('../controllers/clientes');
const suscripcionesCtrl = require('../controllers/suscripciones');
var auth = require('../middlewares/auth');

module.exports = (function () {

	var api = express.Router();
  
  api.get('/', function(req, res, next) {
    res.status(200)
      .json({
        error : false,
        data : { message : 'api-sascha' }
      })
  });
  
  api.get('/suscripciones',      suscripcionesCtrl.getSuscripciones);
  api.post('/suscripciones',     suscripcionesCtrl.saveSuscripcion);
  api.get('/suscripcion/:id',    suscripcionesCtrl.getSuscripcionById);
  api.put('/suscripcion/:id',    suscripcionesCtrl.updateSuscripcion);
  api.delete('/suscripcion/:id', suscripcionesCtrl.deleteSuscripcion);
  api.post('/login',             suscripcionesCtrl.singIn);

/*
  api.get('/clientes',       clientesCtrl.getClientes);
  api.post('/clientes',      clientesCtrl.saveCliente);
  // api.post('/login',         clientesCtrl.singIn);
  api.get('/cliente/:id',    clientesCtrl.getClienteById);
  api.put('/cliente/:id',    clientesCtrl.updateCliente);
  api.delete('/cliente/:id', clientesCtrl.deleteCliente);
*/
	api.get('/users', usersCtrl.getUsers);
  api.post('/users', usersCtrl.saveUser);
  //api.post('/login', usersCtrl.singIn);
  api.get('/users/:id', usersCtrl.getUserById);
  api.put('/users/:id', usersCtrl.updateUser);
  api.delete('/users/:id', usersCtrl.deleteUser);
  	
  return api;

})();