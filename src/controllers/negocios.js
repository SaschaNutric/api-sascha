'use strict';

const Negocios = require('../collections/negocios');
const Negocio  = require('../models/negocio');

function getNegocios(req, res, next) {
	Negocios.query({ where: { estatus: 1 } })
	.fetch({ columns: [
		'id_negocio',
		 'razon_social', 
		 'rif', 
		 'url_logo', 
		 'mision', 
		 'vision', 
		 'objetivo', 
		 'telefono', 
		 'correo', 
		 'latitud', 
		 'longitud'
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

function saveNegocio(req, res, next){
	console.log(JSON.stringify(req.body));

	Negocio.forge({
		 razon_social: req.body.razon_social, 
		 rif: req.body.rif, 
		 url_logo: req.body.url_logo, 
		 mision: req.body.mision, 
		 vision: req.body.vision, 
		 objetivo: req.body.objetivo, 
		 telefono: req.body.telefono, 
		 correo: req.body.correo, 
		 latitud: req.body.latitud, 
		 longitud: req.body.longitud
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

function getNegocioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Negocios.query({where: { id_negocio: id, estatus: 1 } })
		.fetch({ columns: [
			'id_negocio',
		 	'razon_social', 
		 	'rif', 
		 	'url_logo', 
		 	'mision', 
		 	'vision', 
		 	'objetivo', 
		 	'telefono', 
		 	'correo', 
		 	'latitud', 
		 	'longitud'
			] })
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

function updateNegocio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Negocio.forge({ id_negocio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
			razon_social: req.body.razon_social || data.get('razon_social'), 
		 	rif: req.body.rif 					|| data.get('rif'), 
		 	url_logo: req.body.url_logo 		|| data.get('id_tipo_negocio'), 
		 	mision: req.body.mision 			|| data.get('url_logo'), 
		 	vision: req.body.vision 			|| data.get('vision'), 
		 	objetivo: req.body.objetivo 		|| data.get('objetivo'), 
		 	telefono: req.body.telefono 		|| data.get('telefono'), 
		 	correo: req.body.correo 			|| data.get('correo'), 
		 	latitud: req.body.latitud 			|| data.get('latitud'), 
		 	longitud: req.body.longitud 		|| data.get('longitud')
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

function deleteNegocio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Negocio.forge({ id_negocio: id, estatus: 1 })
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
	getNegocios,
	saveNegocio,
	getNegocioById,
	updateNegocio,
	deleteNegocio
}