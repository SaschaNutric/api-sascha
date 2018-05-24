'use strict';

const Red_sociales 	= require('../collections/red_sociales');
const Red_social  	= require('../models/red_social');
const cloudinary = require('../../cloudinary');

function getRed_sociales(req, res, next) {
	Red_sociales.query(function (qb) {
   		qb.where('red_social.estatus', '=', 1);
	})
	.fetch({ columns: ['id_red_social','nombre','usuario', 'url_base','url_logo'] })
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

function saveRed_social(req, res, next){
	console.log(JSON.stringify(req.body));
	if (req.files.imagen) {
		const imagen = req.files.imagen
		cloudinary.uploader.upload(imagen.path, function (result) {
			if (result.error) {
				return res.status(500).json({
					error: true,
					data: { message: result.error }
				});
			}
			Red_social.forge({ 
				nombre:   req.body.nombre,
				usuario:  req.body.usuario,
				url_base: req.body.url_base, 
				url_logo: result.url
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
		});
	}
	else {
		Red_social.forge({
			nombre: req.body.nombre,
			usuario: req.body.usuario,
			url_base: req.body.url_base,
			url_logo: 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png'
		})
		.save()
		.then(function (data) {
			res.status(200).json({
				error: false,
				data: data
			});
		})
		.catch(function (err) {
			res.status(500)
				.json({
					error: true,
					data: { message: err.message }
				});
		});
	}
}

function getRed_socialById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Red_social.forge({ id_red_social: id, estatus: 1 })
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

function updateRed_social(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Red_social.forge({ id_red_social: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		if (req.files.imagen && req.files.imagen.name != data.get('url_logo').substr(65)) {
			const imagen = req.files.imagen
			cloudinary.uploader.upload(imagen.path, function(result) {
				if (result.error) {
					return res.status(500).json({
						error: true,
						data: { message: result.error }
					});
				}
				data.save({ 
					nombre:   req.body.nombre   || data.get('nombre'),
					usuario:  req.body.usuario  || data.get('usuario'),
					url_base: req.body.url_base || data.get('url_base'),
					url_logo: result.url
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
			});
		} else {
			data.save({ 
				nombre:   req.body.nombre   || data.get('nombre'),
				usuario:  req.body.usuario  || data.get('usuario'),
				url_base: req.body.url_base || data.get('url_base'),
				url_logo: req.body.url_logo || data.get('url_logo') 
			})
			.then(function (data) {
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
			})
		}
	})
	.catch(function(err) {
		return res.status(500).json({ 
			error : true, 
			data : { mensaje : err.message } 
		});
	})
}

function deleteRed_social(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Red_social.forge({ id_red_social: id, estatus: 1 })
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
	getRed_sociales,
	saveRed_social,
	getRed_socialById,
	updateRed_social,
	deleteRed_social
}
