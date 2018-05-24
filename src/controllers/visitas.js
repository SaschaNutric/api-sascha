'use strict';

const Visitas 	= require('../collections/visitas');
const Visita  	= require('../models/visita');
const Bookshelf = require('../commons/bookshelf');
const Bluebird  = require('bluebird');
const Empleado  = require('../models/empleado');
const Agenda    = require('../models/agenda');
const Cita      = require('../models/cita');
const ParametrosCliente  = require('../collections/parametro_clientes');
const DetallesVisita     = require('../collections/detalle_visitas');
const RegimenSuplementos = require('../collections/regimen_suplementos');
const RegimenEjercicios  = require('../collections/regimen_ejercicios');
const RegimenDietas      = require('../collections/regimen_dietas');
const DetalleRegimenAlimentos = require('../collections/detalle_regimen_alimentos');

function getVisitas(req, res, next) {
	Visitas.query({})
	.fetch({ columns: ['id_visita','numero','fecha_atencion'] })
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay dato registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: data
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function saveVisita(req, res, next){
	if (!req.body.id_agenda           || !req.body.fecha         || 
		!req.body.id_orden_servicio   || !req.body.id_cliente    ||
		!req.body.id_bloque_horario   || !req.body.id_empleado   ||
		!req.body.fecha_atencion      || !req.body.perfil        ||
		!req.body.regimen_suplementos || !req.body.regimen_dietas||
		!req.body.regimen_ejercicios  || !req.body.id_tipo_cita)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		});
	let query = `select empleado.*, ARRAY(select id_agenda from agenda inner join cita on cita.id_cita = agenda.id_cita where agenda.id_empleado = empleado.id_empleado and cita.id_bloque_horario = ${req.body.id_bloque_horario} and cita.fecha='${req.body.fecha}' and agenda.estatus = 1) as agenda_consultada from empleado where empleado.id_empleado = ${req.body.id_empleado}`;
	Bookshelf.knex.raw(query)
	.then(function (result) {
		let empleado = result.rows[0]
		if (empleado.agenda_consultada.length > 0) {
			return res.status(200).json({
				error: true,
				data: { mensaje: `${empleado.nombres} ${empleado.apellidos} ya tiene una cita agendada el ${req.body.fecha} en el horario seleccionado` }
			})
		}
		else {
			Empleado.query(function (qb) {
				qb.where('empleado.id_empleado', '=', req.body.id_empleado);
				qb.where('empleado.estatus', 1);
			})
			.fetch({ withRelated: ['horario'] })
			.then(function (empleadoBuscado) {
				let horarioValido = false;
				empleadoBuscado.toJSON().horario.map(function (horario) {
					let fechaSolicitud = new Date(req.body.fecha);
					if (horario.id_dia_laborable == fechaSolicitud.getUTCDay()
						&& horario.id_bloque_horario == req.body.id_bloque_horario) {
						horarioValido = true;
					}
				})
				if (!horarioValido) {
					return res.status(200).json({
						error: true,
						data: { mensaje: `${empleadoBuscado.get('nombres')} ${empleadoBuscado.get('apellidos')} no trabaja los dias tal en el horario seleccionado` }
					})
				}
				else {					
					Bookshelf.transaction(function(t) {
						Cita.forge({
							id_orden_servicio: req.body.id_orden_servicio,
							id_tipo_cita: 2,
							id_bloque_horario: req.body.id_bloque_horario,
							fecha: req.body.fecha,
						})
						.save(null, { transacting: t })
						.then(function (cita) {
							Agenda.forge({
								id_empleado: req.body.id_empleado,
								id_cliente: req.body.id_cliente,
								id_orden_servicio: req.body.id_orden_servicio,
								id_cita: cita.get('id_cita')
							})
							.save(null, { transacting: t })
							.then(function (agenda) {
								Visita.forge({ 
									id_agenda: req.body.id_agenda,
									numero: req.body.numero,
									fecha_atencion: req.body.fecha_atencion 
								})
								.save(null, { transacting: t })
								.then(function(visita){		
									let parametros_perfil = ParametrosCliente.forge(req.body.perfil);
									parametros_perfil.invokeThen('save', null, { transacting: t })
									.then(function(parametros) {
										let detalles = req.body.perfil.map(function(parametro) {
											return {
												id_parametro: parametro.id_parametro,
												id_visita: visita.get('id_visita'),
												valor: parametro.valor
											}
										})
	
										let detalles_visita = DetallesVisita.forge(detalles);
										detalles_visita.invokeThen('save', null, { transacting: t })
										.then(function (detalles) {
											let regimen_suplementos =	RegimenSuplementos.forge(req.body.regimen_suplementos);
											regimen_suplementos.invokeThen('save', null, { transacting: t })
											.then(function(suplementos) {
												let regimen_ejercicios = RegimenEjercicios.forge(req.body.regimen_ejercicios)
												regimen_ejercicios.invokeThen('save', null, { transacting: t })
												.then(function(ejercicios) {
													let dietas = req.body.regimen_dietas.map(function(dieta){
														return {
															id_detalle_plan_dieta: dieta.id_detalle_plan_dieta,
															id_cliente:            dieta.id_cliente,
															cantidad:              dieta.cantidad
														}
													})
							
													let regimen_dietas = RegimenDietas.forge(dietas)
													regimen_dietas.invokeThen('save', null, { transacting: t })
													.then(function(regimendietas) {
														Bluebird.map(regimendietas, function(regimen) {
															let regimen_json = regimen.toJSON();
															let alimentos = []
															req.body.regimen_dietas.map(function(dieta) {
																if (dieta.id_detalle_plan_dieta == regimen_json.id_detalle_plan_dieta && 
																	dieta.id_cliente == regimen_json.id_cliente) {
																	dieta.alimentos.map(function(alimento) {
																		alimentos.push({
																			id_alimento: alimento.id_alimento,
																			id_regimen_dieta: regimen_json.id_regimen_dieta
																		})
																	})	
																}
															})
	
															let regimen_alimentos = DetalleRegimenAlimentos.forge(alimentos);
															return regimen_alimentos.invokeThen('save', null, { transacting: t })
														})
														.then(function() {
															t.commit();
															return res.status(200).json({ error: false, data: { mensaje: 'Registro exitoso' } })
														})
														.catch(function (err) {
															t.rollback();
															res.status(500).json({
																error: true,
																data: { message: err.message }
															});
														})
													})
													.catch(function (err) {
														t.rollback();
														res.status(500).json({
															error: true,
															data: { message: err.message }
														});
													})
													
												})
												.catch (function (err) {
													t.rollback();
													res.status(500).json({
														error: true,
														data: { message: err.message }
													});
												})
											})
											.catch(function (err) {
												t.rollback();
												res.status(500).json({
													error: true,
													data: { message: err.message }
												});
											})
										})
										.catch(function (err) {
											t.rollback();
											res.status(500).json({
												error: true,
												data: { message: err.message }
											});
										})
									})
									.catch(function (err) {
										t.rollback();
										res.status(500).json({
											error: true,
											data: { message: err.message }
										});
									})
								})
								.catch(function (err) {
									t.rollback();
									res.status(500).json({
										error: true,
										data: { message: err.message }
									});
								})

							})
							.catch(function (err) {
								return res.status(500).json({
									error: true,
									data: { mensaje: err.message }
								})
							})
						})
						.catch(function (err) {
							return res.status(500).json({
								error: true,
								data: { mensaje: err.message }
							})
						})
					});
				}
			})
			.catch(function (err) {
				return res.status(500).json({
					error: true,
					data: { mensaje: err.message }
				})
			})
		}
	})
	.catch(function(err) {
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		})
	})
}

function getVisitaById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Visita.forge({ id_visita: id, estatus: 1 })
	.fetch()
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'dato no encontrado' } 
			});
		return res.status(200).json({ 
			error : false, 
			data : data 
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function updateVisita(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Visita.forge({ id_visita: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ numero:req.body.numero || data.get('numero'),fecha_atencion:req.body.fecha_atencion || data.get('fecha_atencion') })
		.then(function(data) {
			return res.status(200).json({ 
				error: false, 
				data: data 
			});
		})
		.catch(function(err) {
			return res.status(500).json({ 
				error : true, 
				data : { mensaje : err.message } 
			});
		})
	})
	.catch(function(err) {
		return res.status(500).json({ 
			error : true, 
			data : { mensaje : err.message } 
		});
	})
}

function deleteVisita(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Visita.forge({ id_visita: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrad0' } 
			});

		data.save({ estatus:  0 })
		.then(function() {
			return res.status(200).json({ 
				error: false,
				data: { mensaje: 'Registro eliminado' } 
			});
		})
		.catch(function(err) {
			return res.status(500).json({ 
				error: true, 
				data: { mensaje: err.message} 
			});
		})
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: true, 
			data: { mensaje: err.message } 
		});
	})
}

module.exports = {
	getVisitas,
	saveVisita,
	getVisitaById,
	updateVisita,
	deleteVisita
}
