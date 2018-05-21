'use strict';

const Visitas 	= require('../collections/visitas');
const Visita  	= require('../models/visita');
const Bookshelf = require('../commons/bookshelf');
const Bluebird  = require('bluebird');
const ParametroCliente  = require('../models/parametro_cliente');
const DetalleVisita     = require('../models/detalle_visita');
const RegimenSuplemento = require('../models/regimen_suplemento');
const RegimenEjercicio  = require('../models/regimen_ejercicio');
const RegimenDieta      = require('../models/regimen_dieta');
const DetalleRegimenAlimento = require('../models/detalle_regimen_alimento');

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
	if (!req.body.id_cliente          || !req.body.id_agenda      ||
		!req.body.fecha_atencion      || !req.body.perfil         ||
		!req.body.regimen_suplementos || !req.body.regimen_dietas ||
		!req.body.regimen_ejercicios)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		});
	Bookshelf.transaction(function(t) {
		Visita.forge({ 
			id_agenda: req.body.id_agenda,
			numero: req.body.numero,
			fecha_atencion: req.body.fecha_atencion 
		})
		.save(null, { transacting: t })
		.then(function(data){
			if(req.body.id_tipo_cita == 1) {
				Bluebird.map(req.body.perfil, function(registro) {
					ParametroCliente.forge({ 
						id_parametro: registro.id_parametro, 
						id_cliente: req.body.id_cliente, 
						valor: registro.valor 
					}).save(null, { transacting: t })

					DetalleVisita.forge({
						id_parametro: registro.id_parametro,
						id_cliente: req.body.id_cliente,
						valor: registro.valor
					}).save(null, { transacting: t })
				})
				.then(function(data) {
					Bluebird.map(req.body.regimen_suplementos, function(registro) {
						RegimenSuplemento.forge({
							id_suplemento: registro.id_suplemento,
							id_frecuencia: registro.id_frecuencia,
							id_cliente:    req.body.id_cliente,
							cantidad:      registro.cantidad,
						})
						.save(null, { transacting: t })
					})
					.then(function (data2) {
						Bluebird.map(req.body.regimen_ejercicios, function (registro) {
							RegimenEjercicio.forge({
								id_ejercicio:  registro.id_suplemento,
								id_frecuencia: registro.id_frecuencia,
								id_cliente:    req.body.id_cliente,
								id_tiempo:     req.body.id_tiempo,
								duracion:      registro.duracion,
							})
							.save(null, { transacting: t })
						})
						.then(function(data3) {
							Bluebird.map(req.body.regimen_dietas, function (registro) {							
								RegimenDieta.forge({
									id_detalle_plan_dieta: registro.id_detalle_plan_dieta,
									id_cliente: req.body.id_cliente,
									cantidad: registro.cantidad,
								})
								.save(null, { transacting: t })
								.then(function(regimendieta) {
									Bluebird.map(registro.alimentos, function(alimento) {
										DetalleRegimenAlimento.forge({
											id_regimen_dieta: regimendieta.get('id_regimen_dieta'),
											id_alimento: alimento.id_alimento
										})
										.save(null, { transacting: t })
									})	
								})
							})
							.then(function(data4) {
								t.commit();
								return res.status(201).json({
									error: false,
									data: { mensaje: 'Visita registrada satisfactoriamente' }
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
				.catch(function(err) {
					t.rollback();
					res.status(500).json({
						error: true,
						data: { message: err.message }
					});
				})
			} else if (req.body.id_tipo_cita == 2) {

			} else {
				t.rollback();
				return res.status(400).json({
					error: true,
					data: { mensaje: 'Petición inválida' }
				});	
			}
		})
		.catch(function (err) {
			t.rollback();
			res.status(500).json({
				error: true,
				data: {message: err.message}
			});
		});
	});
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
