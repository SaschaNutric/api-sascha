'use strict';

const Reclamos 	= require('../collections/reclamos');
const Reclamo  	= require('../models/reclamo');

function getReclamos(req, res, next) {
	Reclamos.query(function (qb) {
   		qb.where('reclamo.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
		'motivo', 
		'respuesta', 
		'ordenServicio',
		'ordenServicio.solicitud',
		'ordenServicio.solicitud.cliente',
		'ordenServicio.solicitud.servicio',
		'ordenServicio.solicitud.servicio.condiciones_garantia'
		]
	})
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay dato registrados' } 
			});
		let arrayReclamos = data.toJSON();
		let reclamos = [];
		arrayReclamos.map(function(reclamo) {
			console.log(reclamo);
			reclamos.push({
				id_reclamo: reclamo.id_reclamo,
				id_motivo: reclamo.id_reclamo,
				id_respuesta: reclamo.id_respuesta,
				id_orden_servicio: reclamo.id_orden_servicio,
				respuesta: reclamo.respuesta,
				motivo: reclamo.motivo.descripcion,
				fecha: reclamo.fecha_creacion,
				id_servicio: reclamo.ordenServicio.solicitud.servicio.id_servicio,
				servicio: reclamo.ordenServicio.solicitud.servicio.nombre,
				condiciones_garantia : reclamo.ordenServicio.solicitud.servicio.condiciones_garantia,
				id_cliente: reclamo.ordenServicio.solicitud.cliente.id_cliente,
				cliente: reclamo.ordenServicio.solicitud.cliente.nombres,
			});
		});

		return res.status(200).json({
			error: false,
			data: reclamos
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function saveReclamo(req, res, next){
	console.log(JSON.stringify(req.body));

	Reclamo.forge({ 
		id_motivo:req.body.id_motivo ,
		id_orden_servicio:req.body.id_orden_servicio ,
		id_respuesta:req.body.id_respuesta ,
		respuesta:req.body.respuesta || null 
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

function getReclamoById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Reclamo.forge({ id_reclamo: id, estatus : 1 })
	.fetch({
		withRelated: ['motivo', 'respuesta', 'ordenServicio'],
		columns: ['id_motivo', 'id_orden_servicio', 'id_respuesta', 'respuesta'] 
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

function updateReclamo(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Reclamo.forge({ id_reclamo: id, estatus:1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_motivo:req.body.id_motivo || data.get('id_motivo'),id_orden_servicio:req.body.id_orden_servicio || data.get('id_orden_servicio'),id_respuesta:req.body.id_respuesta || data.get('id_respuesta'),respuesta:req.body.respuesta || data.get('respuesta') })
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

function deleteReclamo(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Reclamo.forge({ id_reclamo })
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
	getReclamos,
	saveReclamo,
	getReclamoById,
	updateReclamo,
	deleteReclamo
}
