var express           = require('express');
var usersCtrl         = require('../controllers/users');
const clientesCtrl    = require('../controllers/clientes');
const usuariosCtrl    = require('../controllers/usuarios');
const serviciosCtrl   = require('../controllers/servicios');
const plan_dietasCtrl = require('../controllers/plan_dietas');
const perfilCtrl      = require('../controllers/perfil');
var auth              = require('../middlewares/auth');

module.exports = (function () {

	var api = express.Router();
  
  api.get('/', function(req, res, next) {
    res.status(200)
      .json({
        error : false,
        data : { message : 'api-sascha' }
      })
  });
  
  api.get('/usuarios',       usuariosCtrl.getUsuarios);
  api.post('/usuarios',      usuariosCtrl.saveUsuario);
  api.get('/usuario/:id',    usuariosCtrl.getUsuarioById);
  api.put('/usuario/:id',    usuariosCtrl.updateUsuario);
  api.delete('/usuario/:id', usuariosCtrl.deleteUsuario);
  api.post('/login',         usuariosCtrl.singIn);

  api.get('/clientes',       clientesCtrl.getClientes);
  api.get('/cliente/:id',    clientesCtrl.getClienteById);

  api.get('/generos',        perfilCtrl.getGeneros);
  api.get('/estados',        perfilCtrl.getEstados);
  api.get('/estados_civil',  perfilCtrl.getEstadosCivil);

/*
  api.post('/clientes',      clientesCtrl.saveCliente);
  // api.post('/login',         clientesCtrl.singIn);
  api.put('/cliente/:id',    clientesCtrl.updateCliente);
  api.delete('/cliente/:id', clientesCtrl.deleteCliente);
*/

/* ------------ Gestion de servicio --------------------- */

  api.get('/servicios',      serviciosCtrl.getServicios);
  api.post('/servicios',     serviciosCtrl.saveServicio);
  api.get('/servicio/:id',  serviciosCtrl.getServicioById);
  

  api.get('/dietas',         plan_dietasCtrl.getPlanDietas);

/* ----------------------------------------------------- */

	api.get('/users', usersCtrl.getUsers);
  api.post('/users', usersCtrl.saveUser);
  //api.post('/login', usersCtrl.singIn);
  api.get('/users/:id', usersCtrl.getUserById);
  api.put('/users/:id', usersCtrl.updateUser);
  api.delete('/users/:id', usersCtrl.deleteUser);
  	
  return api;

})();