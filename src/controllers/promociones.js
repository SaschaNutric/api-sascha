'use strict';

const Promociones = require('../collections/promociones');
const Promocion  = require('../models/promocion');

function getPromociones(req, res, next) {
	Promociones.query(function (qb) {
   		qb.where('promocion.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'servicio',
			'servicio.plan_dieta',
			'servicio.plan_dieta.tipo_dieta',
			'servicio.plan_ejercicio',
			'servicio.plan_suplemento',
			'servicio.precio',
			'servicio.precio.unidad',
			'servicio.precio.unidad.tipo_unidad',
			'genero',
			'estado_civil',
			'rango_edad'
		]})
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

function savePromocion(req, res, next){
	console.log(JSON.stringify(req.body));

	Promocion.forge({
		id_servicio: req.body.id_servicio,
		nombre: req.body.nombre,
		descripcion: req.body.descripcion,
		descuento:   req.body.descuento,
		id_genero: req.body.id_genero,
		id_estado_civil: req.body.id_estado_civil,
		id_rango_edad: req.body.id_rango_edad
	})
	.save()
	.then(function(servicio){
		res.status(200).json({
			error: false,
			data: data
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

function getPromocionById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Promocion.forge({ id_promocion: id, estatus: 1 })
	.fetch({
		withRelated: [
			'servicio',
			'genero',
			'estado_civil',
			'rango_edad'
		]})
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

function updatePromocion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Promocion.forge({ id_promocion: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
			id_servicio: req.body.id_servicio || data.get('id_servicio'),
			nombre: req.body.nombre || data.get('nombre'),
			descripcion: req.body.descripcion || data.get('descripcion'),
			descuento:   req.body.descuento   || data.get('descuento'),
			id_genero: req.body.id_genero || data.get('id_genero'),
			id_estado_civil: req.body.id_estado_civil || data.get('id_estado_civil'),
			id_rango_edad: req.body.id_rango_edad || data.get('id_rango_edad')
		})
		.then(function() {
			return res.status(200).json({ 
				error: false, 
				data: { mensaje: 'Registro actualizado' } 
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

function deletePromocion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Promocion.forge({ id_promocion: id, estatus: 1 })
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
	getPromociones,
	savePromocion,
	getPromocionById,
	updatePromocion,
	deletePromocion
}