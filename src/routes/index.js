var express                       = require('express');

const agendasCtrl                 = require('../controllers/agendas');
const ayudasCtrl                  = require('../controllers/ayudas');
const alimentosCtrl               = require('../controllers/alimentos');
const appmovilesCtrl              = require('../controllers/app_moviles');
const bloquehorariosCtrl          = require('../controllers/bloque_horarios');
const calificacionesCtrl          = require('../controllers/calificaciones');
const citasCtrl                   = require('../controllers/citas');
const clientesCtrl                = require('../controllers/clientes');
const comentariosCtrl             = require('../controllers/comentarios');
const comidasCtrl                 = require('../controllers/comidas');
const condicionGarantiasCtrl      = require('../controllers/condicion_garantias');
const contenidosCtrl              = require('../controllers/contenidos');
const criteriosCtrl               = require('../controllers/criterios');
const detallePlanDietasCtrl       = require('../controllers/detalle_plan_dietas');
const detallePlanEjerciciosCtrl   = require('../controllers/detalle_plan_ejercicios');
const detallePlanSuplementosCtrl  = require('../controllers/detalle_plan_suplementos');
const detalleRegimenAlimentosCtrl = require('../controllers/detalle_regimen_alimentos');
const detalleVisitasCtrl          = require('../controllers/detalle_visitas');
const diaLaborablesCtrl           = require('../controllers/dia_laborables');
const ejerciciosCtrl              = require('../controllers/ejercicios');
const empleadosCtrl               = require('../controllers/empleados');
const especialidadesCtrl          = require('../controllers/especialidades');
const especialidadeEmpleadosCtrl  = require('../controllers/especialidad_empleados');
const especialidadeServiciosCtrl  = require('../controllers/especialidad_servicios');
const estadoCivilesCtrl           = require('../controllers/estado_civiles');
const frecuenciasCtrl             = require('../controllers/frecuencias');
const funcionalidadesCtrl         = require('../controllers/funcionalidades');
const garantiaServiciosCtrl       = require('../controllers/garantia_servicios');
const generosCtrl                 = require('../controllers/generos');
const grupoalimenticiosCtrl       = require('../controllers/grupo_alimenticios');
const horarioEmpleadosCtrl        = require('../controllers/horario_empleados');
const incidenciasCtrl             = require('../controllers/incidencias');
const motivosCtrl                 = require('../controllers/motivos');
const negociosCtrl                = require('../controllers/negocios');
const ordenServiciosCtrl          = require('../controllers/orden_servicios');
const parametrosCtrl              = require('../controllers/parametros');
const parametroClientesCtrl       = require('../controllers/parametro_clientes');
const parametroPromocionesCtrl    = require('../controllers/parametro_promociones');
const parametroServiciosCtrl      = require('../controllers/parametro_servicios');
const plan_dietasCtrl             = require('../controllers/plan_dietas');
const plan_ejerciciosCtrl         = require('../controllers/plan_ejercicios');
const plan_suplementosCtrl        = require('../controllers/plan_suplementos');
const preciosCtrl                 = require('../controllers/precios');
const preferenciaClientesCtrl     = require('../controllers/preferencia_clientes');
const promocionesCtrl             = require('../controllers/promociones');
const rangoEdadesCtrl             = require('../controllers/rango_edades');
const reclamosCtrl                = require('../controllers/reclamos');
const redSocialesCtrl             = require('../controllers/red_sociales');
const regimenDietasCtrl           = require('../controllers/regimen_dietas');
const regimenEjerciciosCtrl       = require('../controllers/regimen_ejercicios');
const regimenSuplementosCtrl      = require('../controllers/regimen_suplementos');
const respuestasCtrl              = require('../controllers/respuestas');
const rolesCtrl                   = require('../controllers/roles');
const rolFuncionalidadesCtrl      = require('../controllers/rol_funcionalidades');
const serviciosCtrl               = require('../controllers/servicios');
const slidesCtrl                  = require('../controllers/slides');
const solicitudServiciosCtrl      = require('../controllers/solicitud_servicios');
const suplementosCtrl             = require('../controllers/suplementos');
const tiemposCtrl                 = require('../controllers/tiempos');
const tipo_citasCtrl              = require('../controllers/tipo_citas');
const tipo_comentariosCtrl        = require('../controllers/tipo_comentarios');
const tipo_criteriosCtrl          = require('../controllers/tipo_criterios');
const tipo_dietasCtrl             = require('../controllers/tipo_dietas');
const tipo_incidenciasCtrl        = require('../controllers/tipo_incidencias');
const tipo_motivosCtrl            = require('../controllers/tipo_motivos');
const tipo_ordenesCtrl            = require('../controllers/tipo_ordenes');
const tipo_parametrosCtrl         = require('../controllers/tipo_parametros');
const tipo_respuestasCtrl         = require('../controllers/tipo_respuestas');
const tipo_unidadesCtrl           = require('../controllers/tipo_unidades');
const tipo_valoracionesCtrl       = require('../controllers/tipo_valoraciones');
const tipo_notificacionesCtrl     = require('../controllers/tipo_notificaciones');
const unidadesCtrl                = require('../controllers/unidades');
const usuariosCtrl                = require('../controllers/usuarios');
const valoracionesCtrl            = require('../controllers/valoraciones');
const visitasCtrl                 = require('../controllers/visitas');

const perfilCtrl                  = require('../controllers/perfil');
var auth                          = require('../middlewares/auth');

module.exports = (function () {

	var api = express.Router();
  
  api.get('/', function(req, res, next) {
    res.status(200)
      .json({
        error : false,
        data : { message : 'api-sascha' }
      })
  });

  api.get('/agendas',                        agendasCtrl.getAgendas);
  api.post('/agendas/empleado/:id_empleado', agendasCtrl.getAgendaPorEmpleado);  
  api.post('/agendas',                       agendasCtrl.saveAgenda);
  api.get('/agenda/:id',                     agendasCtrl.getAgendaById);  
  api.put('/agenda/:id',                     agendasCtrl.updateAgenda);
  api.delete('/agenda/:id',                  agendasCtrl.deleteAgenda);  

  api.get('/ayudas',                         ayudasCtrl.getAyudas);
  api.post('/ayudas',                        ayudasCtrl.saveAyuda);
  api.get('/ayuda/:id',                      ayudasCtrl.getAyudaById);  
  api.put('/ayuda/:id',                      ayudasCtrl.updateAyuda);
  api.delete('/ayuda/:id',                   ayudasCtrl.deleteAyuda);  

  api.get('/alimentos',                      alimentosCtrl.getAlimentos);
  api.post('/alimentos',                     alimentosCtrl.saveAlimento);
  api.get('/alimento/:id',                   alimentosCtrl.getAlimentoById);  
  api.put('/alimento/:id',                   alimentosCtrl.updateAlimento);
  api.delete('/alimento/:id',                alimentosCtrl.deleteAlimento);  
  
  api.get('/appmoviles',                     appmovilesCtrl.getApp_moviles);
  api.post('/appmoviles',                    appmovilesCtrl.saveApp_movil);
  api.get('/appmovil/:id',                   appmovilesCtrl.getApp_movilById);  
  api.put('/appmovil/:id',                   appmovilesCtrl.updateApp_movil);
  api.delete('/appmovil/:id',                appmovilesCtrl.deleteApp_movil);

  api.get('/bloquehorarios',                 bloquehorariosCtrl.getBloque_horarios);
  api.post('/bloquehorarios',                bloquehorariosCtrl.saveBloque_horario);
  api.get('/bloquehorario/:id',              bloquehorariosCtrl.getBloque_horarioById);  
  api.put('/bloquehorario/:id',              bloquehorariosCtrl.updateBloque_horario);
  api.delete('/bloque/horario/:id',          bloquehorariosCtrl.deleteBloque_horario);  

  api.get('/calificaciones',                 calificacionesCtrl.getCalificaciones);
  api.post('/calificaciones',                calificacionesCtrl.saveCalificacion);
  api.get('/calificacion/:id',               calificacionesCtrl.getCalificacionById);  
  api.put('/calificacion/:id',               calificacionesCtrl.updateCalificacion);
  api.delete('/calificacion/:id',            calificacionesCtrl.deleteCalificacion);  

  api.get('/citas',                          citasCtrl.getCitas);
  api.post('/citas',                         citasCtrl.saveCita);
  api.get('/cita/:id',                       citasCtrl.getCitaById);  
  api.put('/cita/:id',                       citasCtrl.updateCita);
  api.delete('/cita/:id',                    citasCtrl.deleteCita);  

  api.get('/clientes',                       clientesCtrl.getClientes);
  api.get('/cliente/:id',                    clientesCtrl.getClienteById);
  api.put('/cliente/:id',                    clientesCtrl.updateCliente);

  api.get('/comentarios',                    comentariosCtrl.getComentarios);
  api.post('/comentarios',                   comentariosCtrl.saveComentario);
  api.get('/comentario/:id',                 comentariosCtrl.getComentarioById);  
  api.put('/comentario/:id',                 comentariosCtrl.updateComentario);
  api.delete('/comentario/:id',              comentariosCtrl.deleteComentario);  

  api.get('/comidas',                        comidasCtrl.getComidas);
  api.post('/comidas',                       comidasCtrl.saveComida);
  api.get('/comida/:id',                     comidasCtrl.getComidaById);  
  api.put('/comida/:id',                     comidasCtrl.updateComida);
  api.delete('/comida/:id',                  comidasCtrl.deleteComida);  

  api.get('/condiciongarantias',             condicionGarantiasCtrl.getCondicion_garantias);
  api.post('/condiciongarantias',            condicionGarantiasCtrl.saveCondicion_garantia);
  api.get('/condiciongarantia/:id',          condicionGarantiasCtrl.getCondicion_garantiaById);  
  api.put('/condiciongarantia/:id',          condicionGarantiasCtrl.updateCondicion_garantia);
  api.delete('/condiciongarantia/:id',      condicionGarantiasCtrl.deleteCondicion_garantia);  

  api.get('/contenidos',                     contenidosCtrl.getContenidos);
  api.post('/contenidos',                    contenidosCtrl.saveContenido);
  api.get('/contenido/:id',                  contenidosCtrl.getContenidoById);  
  api.put('/contenido/:id',                  contenidosCtrl.updateContenido);
  api.delete('/contenido/:id',               contenidosCtrl.deleteContenido);  

  api.get('/comentarios',                    comentariosCtrl.getComentarios);
  api.post('/comentarios',                   comentariosCtrl.saveComentario);
  api.get('/comentario/:id',                 comentariosCtrl.getComentarioById);  
  api.put('/comentario/:id',                 comentariosCtrl.updateComentario);
  api.delete('/comentario/:id',              comentariosCtrl.deleteComentario);  

  api.get('/criterios',                      criteriosCtrl.getCriterios);
  api.post('/criterios',                     criteriosCtrl.saveCriterio);
  api.get('/criterio/:id',                   criteriosCtrl.getCriterioById);  
  api.put('/criterio/:id',                   criteriosCtrl.updateCriterio);
  api.delete('/criterio/:id',                criteriosCtrl.deleteCriterio);  
  
  api.get('/detalleplandietas',              detallePlanDietasCtrl.getDetalle_plan_dietas);
  api.post('/detalleplandietas',             detallePlanDietasCtrl.saveDetalle_plan_dieta);
  api.get('/detalleplandieta/:id',           detallePlanDietasCtrl.getDetalle_plan_dietaById);  
  api.put('/detalleplandieta/:id',           detallePlanDietasCtrl.updateDetalle_plan_dieta);
  api.delete('/detalleplandieta/:id',        detallePlanDietasCtrl.deleteDetalle_plan_dieta);  

  api.get('/detalleplanejercicios',          detallePlanEjerciciosCtrl.getDetalle_plan_ejercicios);
  api.post('/detalleplanejercicios',         detallePlanEjerciciosCtrl.saveDetalle_plan_ejercicio);
  api.get('/detalleplanejercicios/:id',      detallePlanEjerciciosCtrl.getDetalle_plan_ejercicioById);  
  api.put('/detalleplanejercicios/:id',      detallePlanEjerciciosCtrl.updateDetalle_plan_ejercicio);
  api.delete('/detalleplanejercicios/:id',   detallePlanEjerciciosCtrl.deleteDetalle_plan_ejercicio);  

  api.get('/detalleplansuplementos',         detallePlanSuplementosCtrl.getDetalle_plan_suplementos);
  api.post('/detalleplansuplementos',        detallePlanSuplementosCtrl.saveDetalle_plan_suplemento);
  api.get('/detalleplansuplementos/:id',     detallePlanSuplementosCtrl.getDetalle_plan_suplementoById);  
  api.put('/detalleplansuplementos/:id',     detallePlanSuplementosCtrl.updateDetalle_plan_suplemento);
  api.delete('/detalleplansuplementos/:id',  detallePlanSuplementosCtrl.deleteDetalle_plan_suplemento);  

  api.get('/detalleregimenalimentos',        detalleRegimenAlimentosCtrl.getDetalle_regimen_alimentos);
  api.post('/detalleregimenalimentos',       detalleRegimenAlimentosCtrl.saveDetalle_regimen_alimento);
  api.get('/detalleregimenalimento/:id',     detalleRegimenAlimentosCtrl.getDetalle_regimen_alimentoById);  
  api.put('/detalleregimenalimento/:id',     detalleRegimenAlimentosCtrl.updateDetalle_regimen_alimento);
  api.delete('/detalleregimenalimento/:id',  detalleRegimenAlimentosCtrl.deleteDetalle_regimen_alimento);     

  api.get('/detallevisitas',                 detalleVisitasCtrl.getDetalle_visitas);
  api.post('/detallevisitas',                detalleVisitasCtrl.saveDetalle_visita);
  api.get('/detallevisita/:id',              detalleVisitasCtrl.getDetalle_visitaById);  
  api.put('/detallevisita/:id',              detalleVisitasCtrl.updateDetalle_visita);
  api.delete('/detallevisita/:id',           detalleVisitasCtrl.deleteDetalle_visita);     

  api.get('/dialaborables',                  diaLaborablesCtrl.getDia_laborables);
  api.post('/dialaborables',                 diaLaborablesCtrl.saveDia_laborable);
  api.get('/dialaborable/:id',               diaLaborablesCtrl.getDia_laborableById);  
  api.put('/dialaborable/:id',               diaLaborablesCtrl.updateDia_laborable);
  api.delete('/dialaborable/:id',            diaLaborablesCtrl.deleteDia_laborable);   

  api.get('/ejercicios',                     ejerciciosCtrl.getEjercicios);
  api.post('/ejercicios',                    ejerciciosCtrl.saveEjercicio);
  api.get('/ejercicio/:id',                  ejerciciosCtrl.getEjercicioById);  
  api.put('/ejercicio/:id',                  ejerciciosCtrl.updateEjercicio);
  api.delete('/ejercicio/:id',               ejerciciosCtrl.deleteEjercicio);   

  api.get('/empleados',                      empleadosCtrl.getEmpleados);
  api.post('/empleados',                     empleadosCtrl.saveEmpleado);
  api.get('/empleado/:id',                   empleadosCtrl.getEmpleadoById);  
  api.put('/empleado/:id',                   empleadosCtrl.updateEmpleado);
  api.delete('/empleado/:id',                empleadosCtrl.deleteEmpleado);   

  api.get('/especialidades',                 especialidadesCtrl.getEspecialidades);
  api.post('/especialidades',                especialidadesCtrl.saveEspecialidad);
  api.get('/especialidade/:id',              especialidadesCtrl.getEspecialidadById);  
  api.put('/especialidade/:id',              especialidadesCtrl.updateEspecialidad);
  api.delete('/especialidade/:id',           especialidadesCtrl.deleteEspecialidad);   

  api.get('/especialidadeempleados',         especialidadeEmpleadosCtrl.getEspecialidad_empleados);
  api.post('/especialidadeempleados',        especialidadeEmpleadosCtrl.saveEspecialidad_empleado);
  api.get('/especialidadeempleado/:id',      especialidadeEmpleadosCtrl.getEspecialidad_empleadoById);  
  api.put('/especialidadeempleado/:id',      especialidadeEmpleadosCtrl.updateEspecialidad_empleado);
  api.delete('/especialidadeempleado/:id',   especialidadeEmpleadosCtrl.deleteEspecialidad_empleado);   

  api.get('/especialidadeservicios',         especialidadeServiciosCtrl.getEspecialidad_servicios);
  api.post('/especialidadeservicios',        especialidadeServiciosCtrl.saveEspecialidad_servicio);
  api.get('/especialidadeservicio/:id',      especialidadeServiciosCtrl.getEspecialidad_servicioById);  
  api.put('/especialidadeservicio/:id',      especialidadeServiciosCtrl.updateEspecialidad_servicio);
  api.delete('/especialidadeservicio/:id',   especialidadeServiciosCtrl.deleteEspecialidad_servicio);   
  
  api.get('/estadociviles',                  estadoCivilesCtrl.getEstado_civiles);
  api.post('/estadociviles',                 estadoCivilesCtrl.saveEstado_civil);
  api.get('/estadocivil/:id',                estadoCivilesCtrl.getEstado_civilById);  
  api.put('/estadocivil/:id',                estadoCivilesCtrl.updateEstado_civil);
  api.delete('/estado/civil/:id',            estadoCivilesCtrl.deleteEstado_civil);   
  
  api.get('/frecuencias',                    frecuenciasCtrl.getFrecuencias);
  api.post('/frecuencias',                   frecuenciasCtrl.saveFrecuencia);
  api.get('/frecuencia/:id',                 frecuenciasCtrl.getFrecuenciaById);  
  api.put('/frecuencia/:id',                 frecuenciasCtrl.updateFrecuencia);
  api.delete('/frecuencia/:id',              frecuenciasCtrl.deleteFrecuencia);   

  api.get('/funcionalidades',                funcionalidadesCtrl.getFuncionalidades);
  api.post('/funcionalidades',               funcionalidadesCtrl.saveFuncionalidad);
  api.get('/funcionalidad/:id',              funcionalidadesCtrl.getFuncionalidadById);  
  api.put('/funcionalidad/:id',              funcionalidadesCtrl.updateFuncionalidad);
  api.delete('/funcionalidad/:id',           funcionalidadesCtrl.deleteFuncionalidad);   

  api.get('/garantias',                      garantiaServiciosCtrl.getGarantia_servicios);
  api.post('/garantias',                     garantiaServiciosCtrl.saveGarantia_servicio);
  api.get('/garantia/:id',                   garantiaServiciosCtrl.getGarantia_servicioById);  
  api.put('/garantia/:id',                   garantiaServiciosCtrl.updateGarantia_servicio);
  api.delete('/garantia/:id',                garantiaServiciosCtrl.deleteGarantia_servicio);   

  api.get('/generos',                        generosCtrl.getGeneros);
  api.post('/generos',                       generosCtrl.saveGenero);
  api.get('/genero/:id',                     generosCtrl.getGeneroById);  
  api.put('/genero/:id',                     generosCtrl.updateGenero);
  api.delete('/genero/:id',                  generosCtrl.deleteGenero); 

  api.get('/grupoalimenticios',              grupoalimenticiosCtrl.getGrupo_alimenticios);
  api.post('/grupoalimenticios',             grupoalimenticiosCtrl.saveGrupo_alimenticio);
  api.get('/grupoalimenticio/:id',           grupoalimenticiosCtrl.getGrupo_alimenticioById);  
  api.put('/grupoalimenticio/:id',           grupoalimenticiosCtrl.updateGrupo_alimenticio);
  api.delete('/grupoalimenticio/:id',        grupoalimenticiosCtrl.deleteGrupo_alimenticio); 

  api.get('/horarioempleados',               horarioEmpleadosCtrl.getHorario_empleados);
  api.post('/horarioempleados',              horarioEmpleadosCtrl.saveHorario_empleado);
  api.get('/horarioempleado/:id',            horarioEmpleadosCtrl.getHorario_empleadoById);  
  api.put('/horarioempleado/:id',            horarioEmpleadosCtrl.updateHorario_empleado);
  api.delete('/horarioempleado/:id',         horarioEmpleadosCtrl.deleteHorario_empleado);  

  api.get('/incidencias',                    incidenciasCtrl.getIncidencias);
  api.post('/incidencias',                   incidenciasCtrl.saveIncidencia);
  api.get('/incidencia/:id',                 incidenciasCtrl.getIncidenciaById);  
  api.put('/incidencia/:id',                 incidenciasCtrl.updateIncidencia);
  api.delete('/incidencia/:id',              incidenciasCtrl.deleteIncidencia);  

  api.get('/motivos',                        motivosCtrl.getMotivos);
  api.get('/motivos/solicitud',              motivosCtrl.getMotivosDeSolicitud); 
  api.get('/motivos/queja',                  motivosCtrl.getMotivosDeQueja); 
  api.get('/motivos/sugerencia',             motivosCtrl.getMotivosDeSugerencia); 
  api.post('/motivos',                       motivosCtrl.saveMotivo);
  api.get('/motivo/:id',                     motivosCtrl.getMotivoById);  
  api.put('/motivo/:id',                     motivosCtrl.updateMotivo);
  api.delete('/motivo/:id',                  motivosCtrl.deleteMotivo);  
  api.get('/motivo_tipo/:id',                motivosCtrl.getMotivo_tipo);

  api.get('/negocios',                       negociosCtrl.getNegocios);
  api.post('/negocios',                      negociosCtrl.saveNegocio);
  api.get('/negocio/:id',                    negociosCtrl.getNegocioById);  
  api.put('/negocio/:id',                    negociosCtrl.updateNegocio);
  api.delete('/negocio/:id',                 negociosCtrl.deleteNegocio);  

  api.get('/ordenservicios',                 ordenServiciosCtrl.getOrden_servicios);
  api.post('/ordenservicios',                ordenServiciosCtrl.saveOrden_servicio);
  api.get('/ordenservicio/:id',              ordenServiciosCtrl.getOrden_servicioById);
  api.put('/ordenservicio/:id',              ordenServiciosCtrl.updateOrden_servicio);
  api.delete('/ordenservicio/:id',           ordenServiciosCtrl.deleteOrden_servicio);

  api.get('/parametros',                     parametrosCtrl.getParametros);
  api.post('/parametros',                    parametrosCtrl.saveParametro);
  api.get('/parametro/:id',                  parametrosCtrl.getParametroById);
  api.put('/parametro/:id',                  parametrosCtrl.updateParametro);
  api.delete('/parametro/:id',               parametrosCtrl.deleteParametro);

  api.get('/parametroclientes',              parametroClientesCtrl.getParametro_clientes);
  api.post('/parametroclientes',             parametroClientesCtrl.saveParametro_cliente);
  api.get('/parametrocliente/:id',           parametroClientesCtrl.getParametro_clienteById);
  api.put('/parametrocliente/:id',           parametroClientesCtrl.updateParametro_cliente);
  api.delete('/parametrocliente/:id',        parametroClientesCtrl.deleteParametro_cliente);

  api.get('/parametropromociones',           parametroPromocionesCtrl.getParametro_promociones);
  api.post('/parametropromociones',          parametroPromocionesCtrl.saveParametro_promocion);
  api.get('/parametropromocione/:id',        parametroPromocionesCtrl.getParametro_promocionById);
  api.put('/parametropromocione/:id',        parametroPromocionesCtrl.updateParametro_promocion);
  api.delete('/parametropromocione/:id',     parametroPromocionesCtrl.deleteParametro_promocion);

  api.get('/parametroservicios',             parametroServiciosCtrl.getParametro_servicios);
  api.post('/parametroservicios',            parametroServiciosCtrl.saveParametro_servicio);
  api.get('/parametroservicio/:id',          parametroServiciosCtrl.getParametro_servicioById);
  api.put('/parametroservicio/:id',          parametroServiciosCtrl.updateParametro_servicio);
  api.delete('/parametroservicio/:id',       parametroServiciosCtrl.deleteParametro_servicio);
 
  api.get('/plandietas',                     plan_dietasCtrl.getPlanDietas);
  api.post('/plandietas',                    plan_dietasCtrl.savePlanDieta);
  api.get('/plandieta/:id',                  plan_dietasCtrl.getPlanDietaById);
  api.put('/plandieta/:id',                  plan_dietasCtrl.updatePlanDieta);
  api.delete('/plandieta/:id',               plan_dietasCtrl.deletePlanDieta);

  api.get('/planejercicios',                 plan_ejerciciosCtrl.getPlanEjercicios);
  api.post('/planejercicios',                plan_ejerciciosCtrl.savePlanEjercicio);
  api.get('/planejercicio/:id',              plan_ejerciciosCtrl.getPlanEjercicioById);  
  api.put('/planejercicio/:id',              plan_ejerciciosCtrl.updatePlanEjercicio);
  api.delete('/planejercicio/:id',           plan_ejerciciosCtrl.deletePlanEjercicio);

  api.get('/plansuplementos',                plan_suplementosCtrl.getPlanSuplementos);
  api.post('/plansuplementos',               plan_suplementosCtrl.savePlanSuplemento);
  api.get('/plansuplemento/:id',             plan_suplementosCtrl.getPlanSuplementoById);  
  api.put('/plansuplemento/:id',             plan_suplementosCtrl.updatePlanSuplemento);
  api.delete('/plansuplemento/:id',          plan_suplementosCtrl.deletePlanSuplemento);

  api.get('/precios',                        preciosCtrl.getPrecios);
  api.post('/precios',                       preciosCtrl.savePrecio);
  api.get('/precio/:id',                     preciosCtrl.getPrecioById);  
  api.put('/precio/:id',                     preciosCtrl.updatePrecio);
  api.delete('/precio/:id',                  preciosCtrl.deletePrecio);  

  api.get('/preferenciaclientes',            preferenciaClientesCtrl.getPreferencia_clientes);
  api.post('/preferenciaclientes',           preferenciaClientesCtrl.savePreferencia_cliente);
  api.get('/preferenciacliente/:id',         preferenciaClientesCtrl.getPreferencia_clienteById);  
  api.put('/preferenciacliente/:id',         preferenciaClientesCtrl.updatePreferencia_cliente);
  api.delete('/preferenciacliente/:id',      preferenciaClientesCtrl.deletePreferencia_cliente);  

  api.get('/promociones',                    promocionesCtrl.getPromociones);
  api.post('/promociones',                   promocionesCtrl.savePromocion);
  api.get('/promocion/:id',                  promocionesCtrl.getPromocionById);
  api.put('/promocion/:id',                  promocionesCtrl.updatePromocion);
  api.delete('/promocion/:id',               promocionesCtrl.deletePromocion);

  api.get('/rangoedades',                    rangoEdadesCtrl.getRango_edades);
  api.post('/rangoedades',                   rangoEdadesCtrl.saveRango_edad);
  api.get('/rangoedad/:id',                  rangoEdadesCtrl.getRango_edadById);  
  api.put('/rangoedad/:id',                  rangoEdadesCtrl.updateRango_edad);
  api.delete('/rangoedad/:id',               rangoEdadesCtrl.deleteRango_edad);  

  api.get('/reclamos',                       reclamosCtrl.getReclamos);
  api.post('/reclamos',                      reclamosCtrl.saveReclamo);
  api.get('/reclamo/:id',                    reclamosCtrl.getReclamoById);  
  api.put('/reclamo/:id',                    reclamosCtrl.updateReclamo);
  api.delete('/reclamo/:id',                 reclamosCtrl.deleteReclamo);  

  api.get('/redsociales',                    redSocialesCtrl.getRed_sociales);
  api.post('/redsociales',                   redSocialesCtrl.saveRed_social);
  api.get('/redsocial/:id',                  redSocialesCtrl.getRed_socialById);  
  api.put('/redsocial/:id',                  redSocialesCtrl.updateRed_social);
  api.delete('/redsocial/:id',               redSocialesCtrl.deleteRed_social);  

  api.get('/regimen/dietas',                 regimenDietasCtrl.getRegimen_dietas);
  api.post('/regimen/dietas',                regimenDietasCtrl.saveRegimen_dieta);
  api.get('/regimen/dieta/:id',              regimenDietasCtrl.getRegimen_dietaById);  
  api.put('/regimen/dieta/:id',              regimenDietasCtrl.updateRegimen_dieta);
  api.delete('/regimen/dieta/:id',           regimenDietasCtrl.deleteRegimen_dieta);  

  api.get('/regimenejercicios',              regimenEjerciciosCtrl.getRegimen_ejercicios);
  api.post('/regimenejercicios',             regimenEjerciciosCtrl.saveRegimen_ejercicio);
  api.get('/regimenejercicio/:id',           regimenEjerciciosCtrl.getRegimen_ejercicioById);  
  api.put('/regimenejercicio/:id',           regimenEjerciciosCtrl.updateRegimen_ejercicio);
  api.delete('/regimenejercicio/:id',        regimenEjerciciosCtrl.deleteRegimen_ejercicio);  

  api.get('/regimensuplementos',             regimenSuplementosCtrl.getRegimen_suplementos);
  api.post('/regimensuplementos',            regimenSuplementosCtrl.saveRegimen_suplemento);
  api.get('/regimensuplemento/:id',          regimenSuplementosCtrl.getRegimen_suplementoById);  
  api.put('/regimensuplemento/:id',          regimenSuplementosCtrl.updateRegimen_suplemento);
  api.delete('/regimensuplemento/:id',       regimenSuplementosCtrl.deleteRegimen_suplemento);  

  api.get('/respuestas',                     respuestasCtrl.getRespuestas);
  api.post('/respuestas',                    respuestasCtrl.saveRespuesta);
  api.get('/respuesta/:id',                  respuestasCtrl.getRespuestaById);  
  api.put('/respuesta/:id',                  respuestasCtrl.updateRespuesta);
  api.delete('/respuesta/:id',               respuestasCtrl.deleteRespuesta);  

  api.get('/rolfuncionalidades',             rolFuncionalidadesCtrl.getRol_funcionalidades);
  api.post('/rolfuncionalidades',            rolFuncionalidadesCtrl.saveRol_funcionalidad);
  api.get('/rolfuncionalidade/:id',          rolFuncionalidadesCtrl.getRol_funcionalidadById);  
  api.put('/rolfuncionalidade/:id',          rolFuncionalidadesCtrl.updateRol_funcionalidad);
  api.delete('/rolfuncionalidade/:id',       rolFuncionalidadesCtrl.deleteRol_funcionalidad);

  api.get('/roles',                          rolesCtrl.getRoles);
  api.post('/roles',                         rolesCtrl.saveRol);
  api.get('/role/:id',                       rolesCtrl.getRolById);  
  api.put('/role/:id',                       rolesCtrl.updateRol);
  api.delete('/role/:id',                    rolesCtrl.deleteRol);

  api.get('/servicios',                      serviciosCtrl.getServicios);
  api.post('/servicios',                     serviciosCtrl.saveServicio);
  api.get('/servicio/:id',                   serviciosCtrl.getServicioById);
  api.put('/servicio/:id',                   serviciosCtrl.updateServicio);
  api.delete('/servicio/:id',                serviciosCtrl.deleteServicio);

  api.get('/slides',                         slidesCtrl.getSlides);
  api.post('/slides',                        slidesCtrl.saveSlide);
  api.get('/slide/:id',                      slidesCtrl.getSlideById);  
  api.put('/slide/:id',                      slidesCtrl.updateSlide);
  api.delete('/slide/:id',                   slidesCtrl.deleteSlide);

  api.get('/solicitudes',                    solicitudServiciosCtrl.getSolicitud_servicios);
  api.get('/solicitudes/cliente/:id',        solicitudServiciosCtrl.getMiServicioActivo);
  api.post('/solicitudes',                   solicitudServiciosCtrl.saveSolicitud_servicio);
  api.get('/solicitud/:id',                  solicitudServiciosCtrl.getSolicitud_servicioById);  
  api.put('/solicitud/:id',                  solicitudServiciosCtrl.updateSolicitud_servicio);
  api.delete('/solicitud/:id',               solicitudServiciosCtrl.deleteSolicitud_servicio);

  api.get('/suplementos',                    suplementosCtrl.getSuplementos);
  api.post('/suplementos',                   suplementosCtrl.saveSuplemento);
  api.get('/suplemento/:id',                 suplementosCtrl.getSuplementoById);  
  api.put('/suplemento/:id',                 suplementosCtrl.updateSuplemento);
  api.delete('/suplemento/:id',              suplementosCtrl.deleteSuplemento);

  api.get('/tiempos',                        tiemposCtrl.getTiempos);
  api.post('/tiempos',                       tiemposCtrl.saveTiempo);
  api.get('/tiempo/:id',                     tiemposCtrl.getTiempoById);  
  api.put('/tiempo/:id',                     tiemposCtrl.updateTiempo);
  api.delete('/tiempo/:id',                  tiemposCtrl.deleteTiempo);
  
  api.get('/tipocitas',                      tipo_citasCtrl.getTipoCitas);
  api.post('/tipocitas',                     tipo_citasCtrl.saveTipoCita);
  api.get('/tipocita/:id',                   tipo_citasCtrl.getTipoCitaById);  
  api.put('/tipocita/:id',                   tipo_citasCtrl.updateTipoCita);
  api.delete('/tipocita/:id',                tipo_citasCtrl.deleteTipoCita);

  api.get('/tipocomentarios',                tipo_comentariosCtrl.getTipo_comentarios);
  api.post('/tipocomentarios',               tipo_comentariosCtrl.saveTipo_comentario);
  api.get('/tipocomentario/:id',             tipo_comentariosCtrl.getTipo_comentarioById);  
  api.put('/tipocomentario/:id',             tipo_comentariosCtrl.updateTipo_comentario);
  api.delete('/tipocomentario/:id',          tipo_comentariosCtrl.deleteTipo_comentario);

  api.get('/tipocriterios',                  tipo_criteriosCtrl.getTipoCriterios);
  api.post('/tipocriterios',                 tipo_criteriosCtrl.saveTipoCriterio);
  api.get('/tipocriterio/:id',               tipo_criteriosCtrl.getTipoCriterioById);  
  api.put('/tipocriterio/:id',               tipo_criteriosCtrl.updateTipoCriterio);
  api.delete('/tipocriterio/:id',            tipo_criteriosCtrl.deleteTipoCriterio);

  api.get('/tipodietas',                     tipo_dietasCtrl.getTipoDietas);
  api.post('/tipodietas',                    tipo_dietasCtrl.saveTipoDieta);
  api.get('/tipodieta/:id',                  tipo_dietasCtrl.getTipoDietaById);  
  api.put('/tipodieta/:id',                  tipo_dietasCtrl.updateTipoDieta);
  api.delete('/tipodieta/:id',               tipo_dietasCtrl.deleteTipoDieta);

  api.get('/tipoincidencias',                tipo_incidenciasCtrl.getTipoIncidencias);
  api.post('/tipoincidencias',               tipo_incidenciasCtrl.saveTipoIncidencia);
  api.get('/tipoincidencia/:id',             tipo_incidenciasCtrl.getTipoIncidenciaById);  
  api.put('/tipoincidencia/:id',             tipo_incidenciasCtrl.updateTipoIncidencia);
  api.delete('/tipoincidencia/:id',          tipo_incidenciasCtrl.deleteTipoIncidencia);

  api.get('/tipomotivos',                    tipo_motivosCtrl.getTipoMotivos);
  api.post('/tipomotivos',                   tipo_motivosCtrl.saveTipoMotivo);
  api.get('/tipomotivo/:id',                 tipo_motivosCtrl.getTipoMotivoById);  
  api.put('/tipomotivo/:id',                 tipo_motivosCtrl.updateTipoMotivo);
  api.delete('/tipomotivo/:id',              tipo_motivosCtrl.deleteTipoMotivo);
  api.get('/tipomotivos/canalescucha',       tipo_motivosCtrl.getTipoMotivosCanalEscucha);
  
  api.get('/tiponotificaciones',             tipo_notificacionesCtrl.getTipoNotificaciones);
  api.put('/tiponotificaciones/:id',         tipo_notificacionesCtrl.updateTipoNotificacion);

  api.get('/tipoordenes',                    tipo_ordenesCtrl.getTipoOrdenes);
  api.post('/tipoordenes',                   tipo_ordenesCtrl.saveTipoOrden);
  api.get('/tipoorden/:id',                  tipo_ordenesCtrl.getTipoOrdenById);  
  api.put('/tipoorden/:id',                  tipo_ordenesCtrl.updateTipoOrden);
  api.delete('/tipoorden/:id',               tipo_ordenesCtrl.deleteTipoOrden);

  api.get('/tipoparametros',                 tipo_parametrosCtrl.getTipoParametros);
  api.post('/tipoparametros',                tipo_parametrosCtrl.saveTipoParametro);
  api.get('/tipoparametro/:id',              tipo_parametrosCtrl.getTipoParametroById);  
  api.put('/tipoparametro/:id',              tipo_parametrosCtrl.updateTipoParametro);
  api.delete('/tipoparametro/:id',           tipo_parametrosCtrl.deleteTipoParametro);

  api.get('/tiporespuestas',                 tipo_respuestasCtrl.getTipoRespuestas);
  api.post('/tiporespuestas',                tipo_respuestasCtrl.saveTipoRespuesta);
  api.get('/tiporespuesta/:id',              tipo_respuestasCtrl.getTipoRespuestaById);  
  api.put('/tiporespuesta/:id',              tipo_respuestasCtrl.updateTipoRespuesta);
  api.delete('/tiporespuesta/:id',           tipo_respuestasCtrl.deleteTipoRespuesta);

  api.get('/tipounidades',                   tipo_unidadesCtrl.getTipoUnidades);
  api.post('/tipounidades',                  tipo_unidadesCtrl.saveTipoUnidad);
  api.get('/tipounidad/:id',                 tipo_unidadesCtrl.getTipoUnidadById);  
  api.put('/tipounidad/:id',                 tipo_unidadesCtrl.updateTipoUnidad);
  api.delete('/tipounidad/:id',              tipo_unidadesCtrl.deleteTipoUnidad);

  api.get('/tipovaloraciones',               tipo_valoracionesCtrl.getTipoValoraciones);
  api.post('/tipovaloraciones',              tipo_valoracionesCtrl.saveTipoValoracion);
  api.get('/tipovaloracion/:id',             tipo_valoracionesCtrl.getTipoValoracionById);  
  api.put('/tipovaloracion/:id',             tipo_valoracionesCtrl.updateTipoValoracion);
  api.delete('/tipovaloracion/:id',          tipo_valoracionesCtrl.deleteTipoValoracion);

  api.get('/unidades',                       unidadesCtrl.getUnidades);
  api.post('/unidades',                      unidadesCtrl.saveUnidad);
  api.get('/unidad/:id',                     unidadesCtrl.getUnidadById);  
  api.put('/unidad/:id',                     unidadesCtrl.updateUnidad);
  api.delete('/unidad/:id',                  unidadesCtrl.deleteUnidad);  

  api.get('/usuarios',                       usuariosCtrl.getUsuarios);
  api.post('/suscripciones',                 usuariosCtrl.saveUsuario);
  api.get('/usuario/:id',                    usuariosCtrl.getUsuarioById);
  api.put('/usuario/:id',                    usuariosCtrl.updateUsuario);
  api.delete('/usuario/:id',                 usuariosCtrl.deleteUsuario);
  api.post('/login',                         usuariosCtrl.singIn);
  api.post('/login/intranet',                usuariosCtrl.singInEmpleado);

  api.get('/valoraciones',                   valoracionesCtrl.getValoraciones);
  api.post('/valoraciones',                  valoracionesCtrl.saveValoracion);
  api.get('/valoracion/:id',                 valoracionesCtrl.getValoracionById);  
  api.put('/valoracion/:id',                 valoracionesCtrl.updateValoracion);
  api.delete('/valoracion/:id',              valoracionesCtrl.deleteValoracion);  

  api.get('/visitas',                        visitasCtrl.getVisitas);
  api.post('/visitas',                       visitasCtrl.saveVisita);
  api.get('/visita/:id',                     visitasCtrl.getVisitaById);  
  api.put('/visita/:id',                     visitasCtrl.updateVisita);
  api.delete('/visita/:id',                  visitasCtrl.deleteVisita);  

  return api;

})();