'use strict';

const Parametro_promociones = require('../collections/parametro_promociones');
const Parametro_promocion  	= require('../models/parametro_promocion');

function getParametro_promociones(req, res, next) {
	Parametro_promociones.query(function (qb) {
   		qb.where('parametro_promocion.estatus', '=', 1);
	})
	.fetch({ columns: ['id_parametro_promocion','id_parametro','id_promocion','valor_minimo','valor_maximo'] })
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

function saveParametro_promocion(req, res, next){
	Parametro_promocion.forge({ 
		id_parametro: req.body.id_parametro, 
		id_promocion: req.body.id_promocion,
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

function getParametrosByPromocion(req, res, next) {
	const id_promocion = Number.parseInt(req.params.id_promocion);
	if (!id_promocion || id_promocion == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		});

	Parametro_promociones.query(function(qb) { 
		qb.where('id_promocion', '=', id_promocion); 
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

function getParametro_promocionById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Parametro_promocion.forge({ id_parametro_promocion: id, estatus: 1 })
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

function updateParametro_promocion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Parametro_promocion.forge({ id_parametro_promocion: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
<<<<<<< HEAD
		data.save({ 
			valor_minimo:req.body.valor_minimo || data.get('valor_minimo'),
			valor_maximo:req.body.valor_maximo || data.get('valor_maximo') 
		})
=======
		data.save({ id_parametro:req.body.id_parametro || data.get('id_parametro'),id_promocion:req.body.id_promocion || data.get('id_promocion'),valor_minimo:req.body.valor_minimo || data.get('valor_minimo'),valor_maximo:req.body.valor_maximo || data.get('valor_maximo') })
>>>>>>> fa45aa73588fc945ed180fedb109bd1199437281
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

function deleteParametro_promocion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Parametro_promocion.forge({ id_parametro_promocion: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Parametro de la promoción no encontrado' } 
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
	getParametro_promociones,
	saveParametro_promocion,
	getParametro_promocionById,
	updateParametro_promocion,
	deleteParametro_promocion,
	getParametrosByPromocion
}
