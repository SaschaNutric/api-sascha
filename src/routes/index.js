var express                 = require('express');
var usersCtrl               = require('../controllers/users');
const clientesCtrl          = require('../controllers/clientes');
const usuariosCtrl          = require('../controllers/usuarios');
const serviciosCtrl         = require('../controllers/servicios');
const promocionesCtrl       = require('../controllers/promociones');
const plan_dietasCtrl       = require('../controllers/plan_dietas');
const tipo_dietasCtrl       = require('../controllers/tipo_dietas');
const tipo_citasCtrl        = require('../controllers/tipo_citas');
const tipo_criteriosCtrl    = require('../controllers/tipo_criterios');
const tipo_incidenciasCtrl  = require('../controllers/tipo_incidencias');
const tipo_motivosCtrl      = require('../controllers/tipo_motivos');
const tipo_ordenesCtrl      = require('../controllers/tipo_ordenes');
const tipo_parametrosCtrl   = require('../controllers/tipo_parametros');
const tipo_respuestasCtrl   = require('../controllers/tipo_respuestas');
const tipo_unidadesCtrl     = require('../controllers/tipo_unidades');
const unidadesCtrl          = require('../controllers/unidades');
const tipo_valoracionesCtrl = require('../controllers/tipo_valoraciones');
const plan_suplementoCtrl   = require('../controllers/plan_suplementos');
const pla_ejercicioCtrl     = require('../controllers/plan_ejercicios');
const perfilCtrl            = require('../controllers/perfil');
var auth                    = require('../middlewares/auth');

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
  
  api.get('/plandietas',             plan_dietasCtrl.getPlanDietas);
  api.post('/plandietas',            plan_dietasCtrl.savePlanDieta);
  api.get('/plandieta/:id',          plan_dietasCtrl.getPlanDietaById);
  api.put('/plandieta/:id',          plan_dietasCtrl.updatePlanDieta);
  api.delete('/plandieta/:id',       plan_dietasCtrl.deletePlanDieta);

  api.get('/tipodietas',             tipo_dietasCtrl.getTipoDietas);
  api.post('/tipodietas',            tipo_dietasCtrl.saveTipoDieta);
  api.get('/tipodieta/:id',          tipo_dietasCtrl.getTipoDietaById);  
  api.put('/tipodieta/:id',          tipo_dietasCtrl.updateTipoDieta);
  api.delete('/tipodieta/:id',       tipo_dietasCtrl.deleteTipoDieta);

  api.get('/plansuplementos',        plan_suplementoCtrl.getPlanSuplementos);
  api.post('/plansuplementos',       plan_suplementoCtrl.savePlanSuplemento);
  api.get('/plansuplemento/:id',     plan_suplementoCtrl.getPlanSuplementoById);  
  api.put('/plansuplemento/:id',     plan_suplementoCtrl.updatePlanSuplemento);
  api.delete('/plansuplemento/:id',  plan_suplementoCtrl.deletePlanSuplemento);

  api.get('/planejercicios',         pla_ejercicioCtrl.getPlanEjercicios);
  api.post('/planejercicios',        pla_ejercicioCtrl.savePlanEjercicio);
  api.get('/planejercicio/:id',      pla_ejercicioCtrl.getPlanEjercicioById);  
  api.put('/planejercicio/:id',      pla_ejercicioCtrl.updatePlanEjercicio);
  api.delete('/planejercicio/:id',   pla_ejercicioCtrl.deletePlanEjercicio);

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

  api.get('/tipomotivos',             tipo_motivosCtrl.getTipoMotivos);
  api.post('/tipomotivos',            tipo_motivosCtrl.saveTipoMotivo);
  api.get('/tipomotivo/:id',          tipo_motivosCtrl.getTipoMotivoById);  
  api.put('/tipomotivo/:id',          tipo_motivosCtrl.updateTipoMotivo);
  api.delete('/tipomotivo/:id',       tipo_motivosCtrl.deleteTipoMotivo);

  api.get('/tipoordenes',             tipo_ordenesCtrl.getTipoOrdenes);
  api.post('/tipoordenes',            tipo_ordenesCtrl.saveTipoOrden);
  api.get('/tipoorden/:id',           tipo_ordenesCtrl.getTipoOrdenById);  
  api.put('/tipoorden/:id',           tipo_ordenesCtrl.updateTipoOrden);
  api.delete('/tipoorden/:id',        tipo_ordenesCtrl.deleteTipoOrden);

  api.get('/tipoparametros',          tipo_parametrosCtrl.getTipoParametros);
  api.post('/tipoparametros',         tipo_parametrosCtrl.saveTipoParametro);
  api.get('/tipoparametro/:id',       tipo_parametrosCtrl.getTipoParametroById);  
  api.put('/tipoparametro/:id',       tipo_parametrosCtrl.updateTipoParametro);
  api.delete('/tipoparametro/:id',    tipo_parametrosCtrl.deleteTipoParametro);

  api.get('/tiporespuestas',          tipo_respuestasCtrl.getTipoRespuestas);
  api.post('/tiporespuestas',         tipo_respuestasCtrl.saveTipoRespuesta);
  api.get('/tiporespuesta/:id',       tipo_respuestasCtrl.getTipoRespuestaById);  
  api.put('/tiporespuesta/:id',       tipo_respuestasCtrl.updateTipoRespuesta);
  api.delete('/tiporespuesta/:id',    tipo_respuestasCtrl.deleteTipoRespuesta);

  api.get('/tipounidades',            tipo_unidadesCtrl.getTipoUnidades);
  api.post('/tipounidades',           tipo_unidadesCtrl.saveTipoUnidad);
  api.get('/tipounidad/:id',          tipo_unidadesCtrl.getTipoUnidadById);  
  api.put('/tipounidad/:id',          tipo_unidadesCtrl.updateTipoUnidad);
  api.delete('/tipounidad/:id',       tipo_unidadesCtrl.deleteTipoUnidad);

  api.get('/tipovaloraciones',        tipo_valoracionesCtrl.getTipoValoraciones);
  api.post('/tipovaloraciones',       tipo_valoracionesCtrl.saveTipoValoracion);
  api.get('/tipovaloracion/:id',      tipo_valoracionesCtrl.getTipoValoracionById);  
  api.put('/tipovaloracion/:id',      tipo_valoracionesCtrl.updateTipoValoracion);
  api.delete('/tipovaloracion/:id',   tipo_valoracionesCtrl.deleteTipoValoracion);

  api.get('/unidades',                unidadesCtrl.getUnidades);
  api.post('/unidades',               unidadesCtrl.saveUnidad);
  api.get('/unidad/:id',              unidadesCtrl.getUnidadById);  
  api.put('/unidad/:id',              unidadesCtrl.updateUnidad);
  api.delete('/unidad/:id',           unidadesCtrl.deleteUnidad);  

	api.get('/users', usersCtrl.getUsers);
  api.post('/users', usersCtrl.saveUser);
  //api.post('/login', usersCtrl.singIn);
  api.get('/users/:id', usersCtrl.getUserById);
  api.put('/users/:id', usersCtrl.updateUser);
  api.delete('/users/:id', usersCtrl.deleteUser);
  	
  return api;

})();