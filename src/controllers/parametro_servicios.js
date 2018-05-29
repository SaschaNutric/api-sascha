'use strict';

const Parametro_servicios 	= require('../collections/parametro_servicios');
const Parametro_servicio  	= require('../models/parametro_servicio');
const Servicios  			= require('../collections/servicios');

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

async function getServiciosFiltrables(req, res, next) {
	if (!req.body.id_parametros)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida. Faltan campos en el body' }
		})
	Parametro_servicios.query(function (qb) {
		qb.distinct('id_servicio');
   		qb.where({ 
	 		'parametro_servicio.estatus': 1
	 	});
	 	qb.where((builder) =>
  			builder.whereIn('parametro_servicio.id_parametro', req.body.id_parametros)
  		);
	})
	.fetch({ columns: ['id_servicio'] })
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay dato registrados' } 
			});

		let id_servicios=[];
		data.toJSON().map(function(servicio) {
			id_servicios.push(servicio.id_servicio);
		});
		Servicios.query(function (qb) {
   			qb.where({ 
	 			'servicio.estatus': 1
	 		});
	 		qb.where((builder) =>
  				builder.whereIn('servicio.id_servicio', id_servicios)
  			);
   			qb.orderBy('servicio.fecha_creacion','ASC');
		})
		.fetch({
			withRelated: [
				'plan_dieta',
				'plan_ejercicio',
				'plan_suplemento',
				'especialidad',
				'parametros',
				'parametros.parametro',
				'condiciones_garantia'
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
						if(parametro.estatus == 1){
							parametros.push({
								id_parametro_servicio: parametro.id_parametro_servicio,
								id_parametro: parametro.parametro.id_parametro,
								nombre: parametro.parametro.nombre,
								valor_minimo: parametro.valor_minimo,
								valor_maximo: parametro.valor_maximo
							})
						}
					});
					let condiciones = [];
					servicio.condiciones_garantia.map(function (condicion) {
						if (condicion.estatus == 1) {
							condiciones.push({
								id_condicion_garantia: condicion.id_condicion_garantia,
								descripcion: condicion.descripcion
							})
						}
					})
					servicios.push({
						id_servicio: servicio.id_servicio,
						nombre: servicio.nombre,
						descripcion: servicio.descripcion,
						url_imagen: servicio.url_imagen,
						precio: servicio.precio,
						numero_visitas: servicio.numero_visitas,
						fecha_creacion: servicio.fecha_creacion,
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
						parametros: parametros,
						condiciones_garantia: condiciones
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
	getServiciosFiltrables,
	saveParametro_servicio,
	getParametro_servicioById,
	updateParametro_servicio,
	deleteParametro_servicio,
	getParametrosByServicio
}
