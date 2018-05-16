'use strict';

const Servicios  = require('../collections/servicios');
const Servicio   = require('../models/servicio');
const cloudinary = require('../../cloudinary');
const Bookshelf  = require('../commons/bookshelf');

async function getServicios(req, res, next) {
	await Servicios
	.query(function (qb) {
   		qb.groupBy('servicio.id_servicio');
   		qb.where('servicio.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'plan_dieta',
			'plan_ejercicio',
			'plan_suplemento',
			'especialidad',
			'parametros',
			'parametros.parametro',
			'parametros.parametro.unidad'
		]
	})
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay servicios registrados' } 
			});
	
			let servicios = [];
			data.toJSON().map(function(servicio) {
				let parametros = [];
				servicio.parametros.map(function(parametro) {
					parametros.push({
						id_parametro_servicio: parametro.id_parametro_servicio,
						nombre: parametro.parametro.nombre,
						valor_minimo: parametro.valor_minimo,
						valor_maximo: parametro.valor_maximo,
						unidad: parametro.parametro.unidad.abrevitura
					})
				});
				servicios.push({
					id_servicio: servicio.id_servicio,
					nombre: servicio.nombre,
					descripcion: servicio.descripcion,
					url_imagen: servicio.url_imagen,
					precio: servicio.precio,
					numero_visitas: servicio.numero_visitas,
					especialidad: {
						id_especialidad: servicio.especialidad.id_especialidad,
						nombre: servicio.especialidad.nombre
					},
					plan_dieta: { 
						id_plan_dieta: servicio.plan_dieta.id_plan_dieta,
						nombre: servicio.plan_dieta.nombre,
						descripcion: servicio.plan_dieta.descripcion
					},
					plan_ejercicio: servicio.plan_ejercicio ? { 
						id_plan_ejercicio: servicio.plan_ejercicio.id_plan_ejercicio,
						nombre: servicio.plan_ejercicio.nombre,
						descripcion: servicio.plan_ejercicio.descripcion
					} : null,
					plan_suplemento: servicio.plan_suplemento ? { 
						id_plan_suplemento: servicio.plan_suplemento.id_plan_suplemento,
						nombre: servicio.plan_suplemento.nombre,
						descripcion: servicio.plan_suplemento.descripcion
					} : null,
					parametros: parametros
				})
			})
	
		return res.status(200).json({
			error: false,
			data: servicios
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function getServicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Servicio.forge({ id_servicio: id, estatus: 1 })
	.fetch({
		withRelated: [
			'plan_dieta',
			'plan_ejercicio',
			'plan_suplemento',
			'especialidad',
			'parametros',
			'parametros.parametro',
			'parametros.parametro.unidad'
		]
	})
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Servicio no encontrado' } 
			});
		
				let parametros = [];
				let servicio = data.toJSON();
				servicio.parametros.map(function(parametro) {
					parametros.push({
						id_parametro_servicio: parametro.id_parametro_servicio,
						nombre: parametro.parametro.nombre,
						valor_minimo: parametro.valor_minimo,
						valor_maximo: parametro.valor_maximo,
						unidad: parametro.parametro.unidad.abrevitura
					})
				});
				let servicioObtenido = {
					id_servicio: servicio.id_servicio,
					nombre: servicio.nombre,
					descripcion: servicio.descripcion,
					url_imagen: servicio.url_imagen,
					precio: servicio.precio,
					numero_visitas: servicio.numero_visitas,
					especialidad: {
						id_especialidad: servicio.especialidad.id_especialidad,
						nombre: servicio.especialidad.nombre
					},
					plan_dieta: { 
						id_plan_dieta: servicio.plan_dieta.id_plan_dieta,
						nombre: servicio.plan_dieta.nombre,
						descripcion: servicio.plan_dieta.descripcion
					},
					plan_ejercicio: servicio.plan_ejercicio ? { 
						id_plan_ejercicio: servicio.plan_ejercicio.id_plan_ejercicio,
						nombre: servicio.plan_ejercicio.nombre,
						descripcion: servicio.plan_ejercicio.descripcion
					} : null,
					plan_suplemento: servicio.plan_suplemento ? { 
						id_plan_suplemento: servicio.plan_suplemento.id_plan_suplemento,
						nombre: servicio.plan_suplemento.nombre,
						descripcion: servicio.plan_suplemento.descripcion
					} : null,
					parametros: parametros
				}
		return res.status(200).json({ 
			error: false, 
			data: servicioObtenido
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function saveServicio(req, res, next){
	if (req.files.imagen) {
		const imagen = req.files.imagen
		cloudinary.uploader.upload(imagen.path, function(result) {
			if (result.error) {
				return res.status(500).json({
						error: true,
						data: { message: result.error }
					});
			} 

			// usuario.avatarNombre = result.public_id		
			Servicio.forge({
				id_plan_dieta:      req.body.id_plan_dieta,
				id_plan_ejercicio:  req.body.id_plan_ejercicio, 
				id_plan_suplemento: req.body.id_plan_suplemento,
				id_especialidad:    req.body.id_especialidad || null,
				nombre:             req.body.nombre, 
				descripcion:        req.body.descripcion, 
				url_imagen:         result.url, 
				precio:             req.body.precio, 
				numero_visitas:     req.body.numero_visitas
			})
			.save()
			.then(function(data){
				res.status(200).json({
					error: false,
					data: {
						mensaje: "Servicio Creado satisfactoriamente",
						data: data,
					}
				});
			})
			.catch(function (err) {
				res.status(500)
				.json({
					error: true,
					data: {message: err.message}
				});
			});
			
		})
	}
	else {
		Servicio.forge({
			id_plan_dieta:      req.body.id_plan_dieta,
			id_plan_ejercicio:  req.body.id_plan_ejercicio,
			id_plan_suplemento: req.body.id_plan_suplemento,
			id_especialidad:    req.body.id_especialidad || null,
			nombre:             req.body.nombre,
			descripcion:        req.body.descripcion,
			url_imagen:         'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png',
			precio:          req.body.precio,
			numero_visitas:     req.body.numero_visitas
		})
		.save()
		.then(function (data) {
			res.status(200).json({
				error: false,
				data: {
					mensaje: "Servicio Creado satisfactoriamente",
					data: data,
				}
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

function updateServicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Servicio.forge({ id_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
        	nombre: req.body.nombre || data.get('nombre'), 
        	descripcion: req.body.descripcion || data.get('descripcion'), 
        	url_imagen: req.body.url_imagen || data.get('url_imagen'), 
        	precio: req.body.precio || data.get('precio'), 
			numero_visitas: req.body.numero_visitas || data.get('numero_visitas'),
			id_plan_dieta: req.body.id_plan_dieta || data.get('id_plan_dieta'),
			id_plan_ejercicio: req.body.id_plan_ejercicio || data.get('id_plan_ejercicio'),
			id_plan_suplemento: req.body.id_plan_suplemento || data.get('id_plan_suplemento'),
			id_especialidad: req.body.id_especialidad || data.get('id_especialidad')
		})
		.then(function(servicio) {
			return res.status(200).json({ 
				error: false, 
				data: { 
					mensaje: 'Registro de servicio actualizado',
					servicio: servicio
				}
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

function deleteServicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Servicio.forge({ id_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Servicio no encontrada' } 
			});

		data.save({ estatus:  0 })
		.then(function() {
			return res.status(200).json({ 
				error: false,
				data: { mensaje: 'Registro de servicio eliminado' } 
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
	getServicios,
	getServicioById,
	saveServicio,
	updateServicio,
	deleteServicio
}