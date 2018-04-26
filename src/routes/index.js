var express               = require('express');
var usersCtrl             = require('../controllers/users');
const clientesCtrl        = require('../controllers/clientes');
const usuariosCtrl        = require('../controllers/usuarios');
const serviciosCtrl       = require('../controllers/servicios');
const promocionesCtrl     = require('../controllers/promociones');
const plan_dietasCtrl     = require('../controllers/plan_dietas');
const tipo_dietasCtrl     = require('../controllers/tipo_dietas');
const tipo_citasCtrl      = require('../controllers/tipo_citas');
const tipo_criteriosCtrl  = require('../controllers/tipo_criterios');
const tipo_incidenciasCtrl  = require('../controllers/tipo_incidencias');
const plan_suplementoCtrl = require('../controllers/plan_suplementos');
const pla_ejercicioCtrl   = require('../controllers/plan_ejercicios');
const perfilCtrl          = require('../controllers/perfil');

var auth                  = require('../middlewares/auth');

module.exports = (function () {

	var api = express.Router();
  
  api.get('/', function(req, res, next) {
    res.status(200)
      .json({
        error : false,
        data : { message : 'api-sascha' }
      })
  });
  
  api.get('/usuarios',               usuariosCtrl.getUsuarios);
  api.post('/usuarios',              usuariosCtrl.saveUsuario);
  api.get('/usuario/:id',            usuariosCtrl.getUsuarioById);
  api.put('/usuario/:id',            usuariosCtrl.updateUsuario);
  api.delete('/usuario/:id',         usuariosCtrl.deleteUsuario);
  api.post('/login',                 usuariosCtrl.singIn);

  api.get('/clientes',               clientesCtrl.getClientes);
  api.get('/cliente/:id',            clientesCtrl.getClienteById);

  api.get('/generos',                perfilCtrl.getGeneros);
  api.get('/estados',                perfilCtrl.getEstados);
  api.get('/estados_civil',          perfilCtrl.getEstadosCivil);

/*
  api.post('/clientes',      clientesCtrl.saveCliente);
  // api.post('/login',         clientesCtrl.singIn);
  api.put('/cliente/:id',    clientesCtrl.updateCliente);
  api.delete('/cliente/:id', clientesCtrl.deleteCliente);
*/

/* ------------ Gestion de servicio --------------------- */

  api.get('/servicios',              serviciosCtrl.getServicios);
  api.post('/servicios',             serviciosCtrl.saveServicio);
  api.get('/servicio/:id',           serviciosCtrl.getServicioById);
  api.put('/servicio/:id',           serviciosCtrl.updateServicio);
  api.delete('/servicio/:id',        serviciosCtrl.deleteServicio);
  
  api.get('/dietas',                 plan_dietasCtrl.getPlanDietas);
  api.post('/dietas',                plan_dietasCtrl.savePlanDieta);
  api.get('/dieta/:id',              plan_dietasCtrl.getPlanDietaById);
  api.put('/dieta/:id',              plan_dietasCtrl.updatePlanDieta);
  api.delete('/dieta/:id',           plan_dietasCtrl.deletePlanDieta);

  api.get('/tipodietas',             tipo_dietasCtrl.getTipoDietas);
  api.post('/tipodietas',            tipo_dietasCtrl.saveTipoDieta);
  api.get('/tipodieta/:id',          tipo_dietasCtrl.getTipoDietaById);  
  api.put('/tipodieta/:id',          tipo_dietasCtrl.updateTipoDieta);
  api.delete('/tipodieta/:id',       tipo_dietasCtrl.deleteTipoDieta);

  api.get('/suplementos',            plan_suplementoCtrl.getPlanSuplementos);
  api.post('/suplementos',           plan_suplementoCtrl.savePlanSuplemento);
  api.get('/suplemento/:id',         plan_suplementoCtrl.getPlanSuplementoById);  
  api.put('/suplemento/:id',         plan_suplementoCtrl.updatePlanSuplemento);
  api.delete('/suplemento/:id',      plan_suplementoCtrl.deletePlanSuplemento);

  api.get('/ejercicios',             pla_ejercicioCtrl.getPlanEjercicios);
  api.post('/ejercicios',            pla_ejercicioCtrl.savePlanEjercicio);
  api.get('/ejercicio/:id',          pla_ejercicioCtrl.getPlanEjercicioById);  
  api.put('/ejercicio/:id',          pla_ejercicioCtrl.updatePlanEjercicio);
  api.delete('/ejercicio/:id',       pla_ejercicioCtrl.deletePlanEjercicio);

/* ----------------------------------------------------- */

/* ------------ Gestion de promocion --------------------- */

  api.get('/promociones',            promocionesCtrl.getPromociones);
  api.post('/promociones',           promocionesCtrl.savePromocion);
  api.get('/promocion/:id',          promocionesCtrl.getPromocionById);
  api.put('/promocion/:id',          promocionesCtrl.updatePromocion);
  api.delete('/promocion/:id',       promocionesCtrl.deletePromocion);

/* ----------------------------------------------------- */


  api.get('/tipocitas',               tipo_citasCtrl.getTipoCitas);
  api.post('/tipocitas',              tipo_citasCtrl.saveTipoCita);
  api.get('/tipocita/:id',            tipo_citasCtrl.getTipoCitaById);  
  api.put('/tipocita/:id',            tipo_citasCtrl.updateTipoCita);
  api.delete('/tipocita/:id',         tipo_citasCtrl.deleteTipoCita);

  api.get('/tipocriterios',           tipo_criteriosCtrl.getTipoCriterios);
  api.post('/tipocriterios',          tipo_criteriosCtrl.saveTipoCriterio);
  api.get('/tipocriterio/:id',        tipo_criteriosCtrl.getTipoCriterioById);  
  api.put('/tipocriterio/:id',        tipo_criteriosCtrl.updateTipoCriterio);
  api.delete('/tipocriterio/:id',     tipo_criteriosCtrl.deleteTipoCriterio);

  api.get('/tipoincidencias',         tipo_incidenciasCtrl.getTipoIncidencias);
  api.post('/tipoincidencias',        tipo_incidenciasCtrl.saveTipoIncidencia);
  api.get('/tipoincidencia/:id',      tipo_incidenciasCtrl.getTipoIncidenciaById);  
  api.put('/tipoincidencia/:id',      tipo_incidenciasCtrl.updateTipoIncidencia);
  api.delete('/tipoincidencia/:id',   tipo_incidenciasCtrl.deleteTipoIncidencia);

	api.get('/users', usersCtrl.getUsers);
  api.post('/users', usersCtrl.saveUser);
  //api.post('/login', usersCtrl.singIn);
  api.get('/users/:id', usersCtrl.getUserById);
  api.put('/users/:id', usersCtrl.updateUser);
  api.delete('/users/:id', usersCtrl.deleteUser);
  	
  return api;

})();