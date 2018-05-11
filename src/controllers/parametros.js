'use strict';

const Parametros 	= require('../collections/parametros');
const Parametro  	= require('../models/parametro');

function getParametros(req, res, next) {
	Parametros.query(function (qb) {
   		qb.where('parametro.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'tipo_parametro',
			'unidad',
			'unidad.tipo_unidad'
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

function saveParametro(req, res, next){
	Parametro.forge({ 
		id_tipo_parametro:req.body.id_tipo_parametro,
		id_unidad:req.body.id_unidad,
		tipo_valor:req.body.tipo_valor,
		nombre:req.body.nombre  
	})
	.save()
	.then(function(data){
		Parametro.forge({ id_parametro: data.get('id_parametro'), estatus: 1 })
		.fetch({
			withRelated: [
				'tipo_parametro',
				'unidad',
				'unidad.tipo_unidad'
			]
		})
		.then(function(parametro){
			return res.status(200).json({
				error: false,
				data: parametro
			});
		})
		.catch(function (err) {
			res.status(500)
				.json({
					error: true,
					data: { message: err.message }
				});
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

function getParametroById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Parametro.forge({ id_parametro: id, estatus: 1 })
	.fetch({
		withRelated: [
			'tipo_parametro',
			'unidad',
			'unidad.tipo_unidad'
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

function updateParametro(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Parametro.forge({ id_parametro: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_tipo_parametro:req.body.id_tipo_parametro || data.get('id_tipo_parametro'),id_unidad:req.body.id_unidad || data.get('id_unidad'),tipo_valor:req.body.tipo_valor || data.get('tipo_valor'),nombre:req.body.nombre || data.get('nombre') })
		.then(function() {
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

function deleteParametro(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Parametro.forge({ id_parametro: id, estatus: 1 })
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
	getParametros,
	saveParametro,
	getParametroById,
	updateParametro,
	deleteParametro
}
