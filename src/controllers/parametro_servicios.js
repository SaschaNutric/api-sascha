'use strict';

const Parametro_servicios 	= require('../collections/parametro_servicios');
const Parametro_servicio  	= require('../models/parametro_servicio');

function getParametro_servicios(req, res, next) {
	Parametro_servicios.query(function (qb) {
   		qb.where('parametro_servicio.estatus', '=', 1);
	})
	.fetch({ columns: ['id_parametro_servicio','id_servicio','id_parametro','valor_minimo','valor_maximo'] })
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

function saveParametro_servicio(req, res, next){
	Parametro_servicio.forge({ 
		id_servicio: req.body.id_servicio,
		id_parametro: req.body.id_parametro, 
		valor_minimo: req.body.valor_minimo || null, 
		valor_maximo: req.body.valor_maximo || null
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

function getParametrosByServicio(req, res, next) {
	const id_servicio = Number.parseInt(req.params.id_servicio);
	if (!id_servicio || id_servicio == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		});

	Parametro_servicios.query(function (qb) {
		qb.where('id_servicio', '=', id_servicio);
		qb.where('estatus', '=', 1);
	})
	.fetch({ withRelated: ['parametro'] })
	.then(function (data) {
		if (!data)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'Registros no encontrado' }
			});
		return res.status(200).json({
			error: false,
			data: data
		});
	})
	.catch(function (err) {
		return res.status(500).json({
			error: false,
			data: { mensaje: err.message }
		})
	});
}

function getParametro_servicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Parametro_servicio.forge({ id_parametro_servicio: id, estatus: 1 })
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

function updateParametro_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Parametro_servicio.forge({ id_parametro_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ 
			valor_minimo: req.body.valor_minimo || data.get('valor_minimo'),
			valor_maximo: req.body.valor_maximo || data.get('valor_maximo') 
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

function deleteParametro_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Parametro_servicio.forge({ id_parametro_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Parametro en el servicio no encontrado' } 
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
	getParametro_servicios,
	saveParametro_servicio,
	getParametro_servicioById,
	updateParametro_servicio,
	deleteParametro_servicio,
	getParametrosByServicio
}
