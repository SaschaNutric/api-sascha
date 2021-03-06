'use strict';

const Criterios 	= require('../collections/criterios');
const Criterio  	= require('../models/criterio');

function getCriterios(req, res, next) {
	Criterios.query(function (qb) {
   		qb.where('criterio.estatus', '=', 1);
	})
	.fetch({ withRelated: 
		[
			'tipo_criterio',
			'tipo_criterio.tipo_valoracion',
			'tipo_criterio.tipo_valoracion.valoraciones'
			
		] 
	})
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

function getCriteriosServicio(req, res, next) {
	Criterios.query(function (qb) {
		qb.where('criterio.id_tipo_criterio', '=', 1)
		qb.where('criterio.estatus', '=', 1);
	})
		.fetch({
			withRelated:
				[
					'tipo_criterio',
					'tipo_criterio.tipo_valoracion',
					'tipo_criterio.tipo_valoracion.valoraciones'
				]
		})
		.then(function (data) {
			let data_json = data.toJSON();
			if (data_json.length == 0)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay criterios de servicio registrados' }
				});
			let criterios = [];
			data_json.map(function(criterio) {
				let valoraciones = [];
				if (criterio.tipo_criterio.tipo_valoracion.valoraciones) {
					criterio.tipo_criterio.tipo_valoracion.valoraciones.map(function(valoracion) {
						valoraciones.push({
							id_valoracion: valoracion.id_valoracion,
							nombre: valoracion.nombre
						})
					});
				}
				criterios.push({
					id_criterio: criterio.id_criterio,
					nombre: criterio.nombres,
					descripcion: criterio.descripcion,
					tipo_criterio: {
						id_tipo_criterio: criterio.tipo_criterio.id_tipo_criterio,
						nombre: criterio.tipo_criterio.nombre
					},
					tipo_valoracion: {
						id_tipo_valoracion: criterio.tipo_criterio.tipo_valoracion.id_tipo_valoracion,
						nombre: criterio.tipo_criterio.tipo_valoracion.nombre
					},
					valoraciones: valoraciones
				})
			})
			return res.status(200).json({
				error: false,
				data: criterios
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}

function getCriteriosVisita(req, res, next) {
	Criterios.query(function (qb) {
		qb.where('criterio.id_tipo_criterio', '=', 2)
		qb.where('criterio.estatus', '=', 1);
	})
		.fetch({
			withRelated:
				[
					'tipo_criterio',
					'tipo_criterio.tipo_valoracion',
					'tipo_criterio.tipo_valoracion.valoraciones'
				]
		})
		.then(function (data) {
			let data_json = data.toJSON();
			if (data_json.length == 0)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay criterios de servicio registrados' }
				});
			let criterios = [];
			data_json.map(function (criterio) {
				let valoraciones = [];
				if (criterio.tipo_criterio.tipo_valoracion.valoraciones) {
					criterio.tipo_criterio.tipo_valoracion.valoraciones.map(function (valoracion) {
						valoraciones.push({
							id_valoracion: valoracion.id_valoracion,
							nombre: valoracion.nombre
						})
					});
				}
				criterios.push({
					id_criterio: criterio.id_criterio,
					nombre: criterio.nombres,
					descripcion: criterio.descripcion,
					tipo_criterio: {
						id_tipo_criterio: criterio.tipo_criterio.id_tipo_criterio,
						nombre: criterio.tipo_criterio.nombre
					},
					tipo_valoracion: {
						id_tipo_valoracion: criterio.tipo_criterio.tipo_valoracion.id_tipo_valoracion,
						nombre: criterio.tipo_criterio.tipo_valoracion.nombre
					},
					valoraciones: valoraciones
				})
			})
			return res.status(200).json({
				error: false,
				data: criterios
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}

function saveCriterio(req, res, next){
	Criterio.forge({ 
		id_tipo_criterio: 	req.body.id_tipo_criterio ,
		nombre: 			req.body.nombre ,
		descripcion: 		req.body.descripcion  
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

function getCriterioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Criterio.forge({ id_criterio: id, estatus: 1 })
	.fetch({
		withRelated: [
			'tipo_criterio'
		] 
	})
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

function updateCriterio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Criterio.forge({ id_criterio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ 
			id_tipo_criterio:req.body.id_tipo_criterio || data.get('id_tipo_criterio'),
			nombre:req.body.nombre || data.get('nombre'),
			descripcion:req.body.descripcion || data.get('descripcion') 
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

function deleteCriterio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Criterio.forge({ id_criterio: id, estatus: 1 })
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
	getCriterios,
	getCriteriosVisita,
	getCriteriosServicio,
	saveCriterio,
	getCriterioById,
	updateCriterio,
	deleteCriterio
}
