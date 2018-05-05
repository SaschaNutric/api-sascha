'use strict';

const Bookshelf             = require('../commons/bookshelf');
const Solicitud_servicios 	= require('../collections/solicitud_servicios');
const Solicitud_servicio  	= require('../models/solicitud_servicio');
const Orden_servicio      	= require('../models/orden_servicio');
const Cita                  = require('../models/cita');
const Agenda                = require('../models/agenda');

function getSolicitud_servicios(req, res, next) {
	Solicitud_servicios.query(function (qb) {
   		qb.where('solicitud_servicio.estatus', '=', 1);
	})
	.fetch()
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

function saveSolicitud_servicio(req, res, next){
	console.log(JSON.stringify(req.body));
	Bookshelf.transaction(function(transaction) {

		Solicitud_servicio.forge({ 
			id_cliente:req.body.id_cliente,
			id_servicio:req.body.id_servicio,
			id_promocion:req.body.id_promocion,  
			id_motivo:req.body.id_motivo,
			id_respuesta:req.body.id_respuesta || null,
			respuesta:req.body.respuesta || null
		})
		.save()
		.then(function(solicitud){
			Orden_servicio.forge({
				id_solicitud_servicio: solicitud.get('id_solicitud_servicio'),
			})
			.save()
			.then(function(orden) {
				Cita.forge({
					id_orden_servicio: orden.get('id_orden_servicio'),
					id_tipo_cita: 1,
					id_bloque_horario: req.body.id_bloque_horario,
					fecha: req.body.fecha,
				})
				.save()
				.then(function(cita) {

					Agenda.forge({
						id_empleado: req.body.id_empleado,
						id_cliente: req.body.id_cliente,
						id_orden_servicio: orden.get('id_orden_servicio'),
						id_cita: cita.get('id_cita')
					})
					.save()
					.then(function(agenda) {
						res.status(200).json({
							error: false,
							data: `Cita agendada satisfactoriamente para ${cita.get('fecha')}`
						});
					})
					.catch(function (err) {
					transaction.rollback();
						res.status(500)
						.json({
							error: true,
							data: {message: err.message}
						});
					});					
				})
				.catch(function (err) {
					transaction.rollback();
					res.status(500)
					.json({
						error: true,
						data: {message: err.message}
					});
				});
			})
			.catch(function (err) {
				transaction.rollback();
				res.status(500)
				.json({
					error: true,
					data: {message: err.message}
				});
			});
		})
		.catch(function (err) {
			transaction.rollback();
			res.status(500)
			.json({
				error: true,
				data: {message: err.message}
			});
		});
	})
}

function getSolicitud_servicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Solicitud_servicio.forge({ id_solicitud_servicio: id, estatus: 1 })
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

function updateSolicitud_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Solicitud_servicio.forge({ id_solicitud_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_cliente:req.body.id_cliente || data.get('id_cliente'),id_motivo:req.body.id_motivo || data.get('id_motivo'),id_respuesta:req.body.id_respuesta || data.get('id_respuesta'),id_servicio:req.body.id_servicio || data.get('id_servicio'),respuesta:req.body.respuesta || data.get('respuesta'),id_promocion:req.body.id_promocion || data.get('id_promocion') })
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

function deleteSolicitud_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Solicitud_servicio.forge({ id_solicitud_servicio: id, estatus: 1 })
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
	getSolicitud_servicios,
	saveSolicitud_servicio,
	getSolicitud_servicioById,
	updateSolicitud_servicio,
	deleteSolicitud_servicio
}
