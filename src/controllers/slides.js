'use strict';

const Slides 	= require('../collections/slides');
const Slide  	= require('../models/slide');
const cloudinary = require('../../cloudinary');

function getSlides(req, res, next) {
	Slides.query(function (qb) {
		qb.where('slide.estatus', '=', 1).orderBy('orden');
	})
	.fetch({ columns: ['id_slide','titulo','descripcion','orden','url_imagen'] })
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

function saveSlide(req, res, next) {
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

			Slide.forge({ 
				titulo:      req.body.titulo || null, 
				descripcion: req.body.descripcion || null,
				orden:       req.body.orden || null,
				url_imagen:  result.url  
			})
			.save()
			.then(function(data){
				res.status(200).json({
					error: false,
					data: data
				});
			})
			.catch(function (err) {
				res.status(500).json({
					error: true,
					data: {message: err.message}
				});
			});
		})
	}
	else {
		Slide.forge({
			titulo:      req.body.titulo || null,
			descripcion: req.body.descripcion || null,
			orden:       req.body.orden || null,
			url_imagen:  'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png'
		})
		.save()
		.then(function (data) {
			res.status(200).json({
				error: false,
				data: data
			});
		})
		.catch(function (err) {
			res.status(500).json({
				error: true,
				data: { message: err.message }
			});
		});
	}
}

function getSlideById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Slide.forge({ id_slide: id, estatus: 1 })
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

function updateSlide(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Slide.forge({ id_slide: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ 
			titulo:      req.body.titulo      || data.get('titulo'),
			descripcion: req.body.descripcion || data.get('descripcion'),
			orden:       req.body.orden       || data.get('orden'), 
			url_imagen:  req.body.url_imagen  || data.get('url_imagen') 
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

function deleteSlide(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Slide.forge({ id_slide: id, estatus: 1 })
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
	getSlides,
	saveSlide,
	getSlideById,
	updateSlide,
	deleteSlide
}
