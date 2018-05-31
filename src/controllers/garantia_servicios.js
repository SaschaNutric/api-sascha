'use strict';

const Garantia_servicios 	= require('../collections/garantia_servicios');
const Garantia_servicio  	= require('../models/garantia_servicio');
const Bluebird  = require('bluebird');
const Bookshelf = require('../commons/bookshelf');

function getGarantia_servicios(req, res, next) {
	Garantia_servicios.query(function (qb) {
   		qb.where('garantia_servicio.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'servicio',
			'servicio.plan_dieta',
			'servicio.plan_ejercicio',
			'servicio.plan_suplemento',
			'condicion_garantia'
		] })
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

function saveGarantia_servicio(req, res, next){
	if (!req.body.condiciones || !req.body.id_servicio)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		})
	Bluebird.map(req.body.condiciones, function (condicion) {
		Garantia_servicio.forge({
			id_condicion_garantia: condicion.id_condicion_garantia,
			id_servicio:           req.body.id_servicio
		})
		.save()
	})
	.then(function(data){
		let respuesta = {
			id_servicio: req.body.id_servicio,
			condiciones: req.body.condiciones
		}
		return res.status(200).json({
			error: false,
			data: respuesta
		});
	})
	.catch(function (err) {
		res.status(500)
		.json({
			error: true,
			data: {message: err.message}
		});
	});
}

function getGarantia_servicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Garantia_servicio.forge({ id_garantia_servicio: id })
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

function updateGarantia_servicio(req, res, next) {
	const id_servicio = Number.parseInt(req.params.id);
	if (!req.body.condiciones || id_servicio == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		})
		Garantia_servicios.query(function(qb) {
			qb.where('id_servicio', '=', id_servicio).delete();
		})
		.fetch()
		.then(function() {
			Bluebird.map(req.body.condiciones, function (condicion) {
				Garantia_servicio.forge({
					id_condicion_garantia: condicion.id_condicion_garantia,
					id_servicio: id_servicio
				})
				.save()
				.catch(function(err) {
					return res.status(500).json({
							error: true,
							data: { message: err.message }
						});	
				})
			})
			.then(function (data) {
				let respuesta = {
					id_servicio: id_servicio,
					condiciones: req.body.condiciones
				}
				return res.status(200).json({
					error: false,
					data: respuesta
				});
			})
			.catch(function (err) {
				return res.status(500).json({
						error: true,
						data: { message: err.message }
					});
			});
		})
		.catch(function(err) {			
			return res.status(500).json({
					error: true,
					data: { message: err.message }
				});
		})
}

function deleteGarantia_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Garantia_servicio.forge({ id_garantia_servicio: id })
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
	getGarantia_servicios,
	saveGarantia_servicio,
	getGarantia_servicioById,
	updateGarantia_servicio,
	deleteGarantia_servicio
}
