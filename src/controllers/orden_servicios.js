'use strict';

const Orden_servicios 	= require('../collections/orden_servicios');
const Orden_servicio  	= require('../models/orden_servicio');

function getOrden_servicios(req, res, next) {
	Orden_servicios.query(function (qb) {
   		qb.where('orden_servicio.estatus', '=', 1);
	})
	.fetch({ columns: ['id_orden_servicio','id_solicitud_servicio','id_tipo_orden','id_meta','fecha_emision','fecha_caducidad','id_reclamo'] })
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

function saveOrden_servicio(req, res, next){
	console.log(JSON.stringify(req.body));

	Orden_servicio.forge({ id_solicitud_servicio:req.body.id_solicitud_servicio ,id_tipo_orden:req.body.id_tipo_orden ,id_meta:req.body.id_meta ,fecha_emision:req.body.fecha_emision ,fecha_caducidad:req.body.fecha_caducidad ,id_reclamo:req.body.id_reclamo  })
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

function getOrden_servicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Orden_servicio.forge({ id_orden_servicio: id, estatus: 1 })
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

function updateOrden_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Orden_servicio.forge({ id_orden_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_solicitud_servicio:req.body.id_solicitud_servicio || data.get('id_solicitud_servicio'),id_tipo_orden:req.body.id_tipo_orden || data.get('id_tipo_orden'),id_meta:req.body.id_meta || data.get('id_meta'),fecha_emision:req.body.fecha_emision || data.get('fecha_emision'),fecha_caducidad:req.body.fecha_caducidad || data.get('fecha_caducidad'),id_reclamo:req.body.id_reclamo || data.get('id_reclamo') })
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

function deleteOrden_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Orden_servicio.forge({ id_orden_servicio: id, estatus: 1 })
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
	getOrden_servicios,
	saveOrden_servicio,
	getOrden_servicioById,
	updateOrden_servicio,
	deleteOrden_servicio
}
