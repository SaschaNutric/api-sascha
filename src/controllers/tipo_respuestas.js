'use strict';

const TipoRespuestas = require('../collections/tipo_respuestas');
const TipoRespuesta  = require('../models/tipo_respuesta');

function getTipoRespuestas(req, res, next) {
	TipoRespuestas.query(function (qb) {
		qb.where('tipo_respuesta.estatus', '=', 1);
	})
	.fetch({ withRelated: ['respuestas'] })
	.then(function (data) {
		if (!data)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'No hay datos registrados' }
			});
		/*
		let tipoRespuestas = [];
		data.toJSON().map(function (tipoRespuesta) {
			let respuestas = [];
			tipoRespuesta.repuestas.map(function (respuesta) {
				if (respuesta.estatus == 1) {
					respuestas.push({
						id_respuesta: respuesta.id_respuesta,
						descripcion: respuesta.descripcion
					})
				}
			});
			tipoRespuestas.push({
				id_tipo_respuesta: tipoRespuesta.id_tipo_respuesta,
				nombre: tipoRespuesta.nombre.trim(),
				respuestas: respuestas
			})
		});*/
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

function saveTipoRespuesta(req, res, next){
	console.log(JSON.stringify(req.body));

	TipoRespuesta.forge({
        nombre: req.body.nombre
	})
	.save()
	.then(function(data){
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

function getTipoRespuestaById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	TipoRespuesta.forge({ id_tipo_respuesta: id, estatus: 1 })
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

function updateTipoRespuesta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	TipoRespuesta.forge({ id_tipo_respuesta: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
			nombre: req.body.nombre || data.get('nombre')
		})
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

function deleteTipoRespuesta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	TipoRespuesta.forge({ id_tipo_respuesta: id, estatus: 1 })
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
	getTipoRespuestas,
	saveTipoRespuesta,
	getTipoRespuestaById,
	updateTipoRespuesta,
	deleteTipoRespuesta
}
