'use strict';

const TipoUnidades = require('../collections/tipo_unidades');
const TipoUnidad  = require('../models/tipo_unidad');

function getTipoUnidades(req, res, next) {
	TipoUnidades.query(function (qb) {
   		qb.where('tipo_unidad.estatus', '=', 1);
	})
	.fetch()
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

function saveTipoUnidad(req, res, next){
	console.log(JSON.stringify(req.body));

	TipoUnidad.forge({
        nombre: req.body.nombre
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

function getTipoUnidadById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	TipoUnidad.forge({ id_tipo_unidad: id, estatus: 1 })
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

function updateTipoUnidad(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	TipoUnidad.forge({ id_tipo_unidad: id, estatus: 1 })
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

function deleteTipoUnidad(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	TipoUnidad.forge({ id_tipo_unidad: id, estatus: 1 })
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
	getTipoUnidades,
	saveTipoUnidad,
	getTipoUnidadById,
	updateTipoUnidad,
	deleteTipoUnidad
}