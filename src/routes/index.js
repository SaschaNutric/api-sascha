var express = require('express');
var usersCtrl = require('../controllers/users');
const clientesCtrl = require('../controllers/clientes');
const usuariosCtrl = require('../controllers/usuarios');
const perfilCtrl = require('../controllers/perfil');
var auth = require('../middlewares/auth');

module.exports = (function () {

	var api = express.Router();
  
  api.get('/', function(req, res, next) {
    res.render('index', { title: 'Express' });
  });
  
  api.get('/usuarios',       usuariosCtrl.getUsuarios);
  api.post('/usuarios',      usuariosCtrl.saveUsuario);
  api.get('/usuario/:id',    usuariosCtrl.getUsuarioById);
  api.put('/usuario/:id',    usuariosCtrl.updateUsuario);
  api.delete('/usuario/:id', usuariosCtrl.deleteUsuario);
  api.post('/login',         usuariosCtrl.singIn);

  api.get('/clientes',       clientesCtrl.getClientes);
  api.get('/cliente/:id',    clientesCtrl.getClienteById);

  api.get('/generos',       perfilCtrl.getGeneros);
  api.get('/estados',       perfilCtrl.getEstados);
  api.get('/estados_civil', perfilCtrl.getEstadosCivil);

/*
  api.post('/clientes',      clientesCtrl.saveCliente);
  // api.post('/login',         clientesCtrl.singIn);
  api.put('/cliente/:id',    clientesCtrl.updateCliente);
  api.delete('/cliente/:id', clientesCtrl.deleteCliente);
*/
  	
  return api;

})();