'use strict';

const Bookshelf             = require('../commons/bookshelf');
const Solicitud_servicios 	= require('../collections/solicitud_servicios');
const Solicitud_servicio  	= require('../models/solicitud_servicio');
const Orden_servicio      	= require('../models/orden_servicio');
const Cita                  = require('../models/cita');
const Agenda                = require('../models/agenda');
const Empleado              = require('../models/empleado');
const VistaClienteOrdenes   = require('../models/vista_cliente_ordenes');


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
	
	if (!req.body.id_cliente || !req.body.id_empleado
		|| !req.body.id_servicio
		|| !req.body.id_bloque_horario
		|| !req.body.fecha
		|| !req.body.id_motivo
		|| !req.body.acepto_precio) {
			return res.status(400).json({
				error: true,
				data: { mensaje: 'Petición inválida. Faltan parámetros en el Body' }
			})
	} 
	else {
	
		VistaClienteOrdenes.forge({ id_cliente: req.body.id_cliente })
		.fetch()
		.then(function (cliente) {
			if(cliente.toJSON().ordenes.length > 0) 
			return res.status(200).json({
				error: true,
				data: { mensaje: 'Cliente ya tiene un servicio activo' }
			})
			
			if(req.body.acepto_precio === 'no') {
				Solicitud_servicio.forge({
					id_cliente: req.body.id_cliente,
					id_servicio: req.body.id_servicio,
					id_promocion: req.body.id_promocion || null,
					id_motivo: req.body.id_motivo,
					id_respuesta: req.body.id_respuesta || null,
					respuesta: req.body.respuesta || null,
					id_estado_solicitud: 4
				})
				.save()
				.then(function (solicitud) {
					return res.status(200).json({
						error: true,
						data: { mensaje: 'Cliente ha rechazado el precio del servicio' }
					})
				})
				.catch(function (err) {
					res.status(500)
						.json({
							error: true,
							data: { mensaje: err.message }
						});
				});
			}
			else {

				let query = `select empleado.*, ARRAY(select id_agenda from agenda inner join cita on cita.id_cita = agenda.id_cita where agenda.id_empleado = empleado.id_empleado and cita.id_bloque_horario = ${req.body.id_bloque_horario} and cita.fecha='${req.body.fecha}' and agenda.estatus = 1) as agenda_consultada from empleado where empleado.id_empleado = ${req.body.id_empleado}`;
				Bookshelf.knex.raw(query)
				.then(function(result) {
					let empleado = result.rows[0]
					if(empleado.agenda_consultada.length > 0) {
						Solicitud_servicio.forge({
							id_cliente: req.body.id_cliente,
							id_servicio: req.body.id_servicio,
							id_promocion: req.body.id_promocion || null,
							id_motivo: req.body.id_motivo,
							id_respuesta: req.body.id_respuesta || null,
							respuesta: req.body.respuesta || null,
							id_estado_solicitud: 2
						})
						.save()
						.then(function(solicitud) { 
							return res.status(200).json({
								error: true,
								data: { mensaje: `${empleado.nombres} ${empleado.apellidos} ya tiene una cita agendada el ${req.body.fecha} en el horario seleccionado` }
							})
						})
						.catch(function(err) {
							return res.status(500)
								.json({
									error: true,
									data: { mensaje: err.message }
								});
						});
					}
					else {
		
						Empleado.query(function (qb) {
							qb.where('empleado.id_empleado', '=', req.body.id_empleado);
							qb.where('empleado.estatus', 1);
						})
						.fetch({ withRelated: ['horario'] })
						.then(function (empleadoBuscado) {
							let horarioValido = false; 
							empleadoBuscado.toJSON().horario.map(function(horario) {
								console.log(horario)
								let fechaPartes    = req.body.fecha.split('-'); 
								let fechaSolicitud = new Date(fechaPartes[0], fechaPartes[1] - 1, fechaPartes[2]);
								console.log('dia: ' + fechaSolicitud.getDay() + ' Bloque: ' + req.body.id_bloque_horario);
								if (horario.id_dia_laborable == fechaSolicitud.getDay() 
									&& horario.id_bloque_horario == req.body.id_bloque_horario) {
										horarioValido = true;
									}
							})
							if(!horarioValido) {
								Solicitud_servicio.forge({
									id_cliente: req.body.id_cliente,
									id_servicio: req.body.id_servicio,
									id_promocion: req.body.id_promocion || null,
									id_motivo: req.body.id_motivo,
									id_respuesta: req.body.id_respuesta || null,
									respuesta: req.body.respuesta || null,
									id_estado_solicitud: 3
								})
								.save()
								.then(function (solicitud) {
									return res.status(200).json({
										error: true,
										data: { mensaje: `${empleadoBuscado.get('nombres')} ${empleadoBuscado.get('apellidos')} no trabaja los dias tal en el horario seleccionado` }
									})
								})
								.catch(function (err) {
									return res.status(500)
										.json({
											error: true,
											data: { mensaje: err.message }
										});
								});
			
							}
							else {
			
								Bookshelf.transaction(function (transaction) {
									Solicitud_servicio.forge({
										id_cliente: req.body.id_cliente,
										id_servicio: req.body.id_servicio,
										id_promocion: req.body.id_promocion,
										id_motivo: req.body.id_motivo,
										id_respuesta: req.body.id_respuesta || null,
										respuesta: req.body.respuesta || null,
										id_estado_solicitud: 1
									})
									.save(null, { transacting: transaction })
									.then(function (solicitud) {
										Orden_servicio.forge({
											id_solicitud_servicio: solicitud.get('id_solicitud_servicio'),
										})
										.save(null, { transacting: transaction })
										.then(function (orden) {
											Cita.forge({
												id_orden_servicio: orden.get('id_orden_servicio'),
												id_tipo_cita: 1,
												id_bloque_horario: req.body.id_bloque_horario,
												fecha: req.body.fecha,
											})
											.save(null, { transacting: transaction })
											.then(function (cita) {
												Agenda.forge({
													id_empleado: req.body.id_empleado,
													id_cliente: req.body.id_cliente,
													id_orden_servicio: orden.get('id_orden_servicio'),
													id_cita: cita.get('id_cita')
												})
												.save(null, { transacting: transaction })
												.then(function (agenda) {
													transaction.commit();
													return res.status(200).json({
														error: false,
														data: { mensaje: `Solicitud aprobada y agendada satisfactoriamente para ${cita.get('fecha')}` }
													});
												})
												.catch(function (err) {
													transaction.rollback();
													return res.status(500)
														.json({
															error: true,
															data: { mensaje: err.message }
														});
												});
											})
											.catch(function (err) {
												transaction.rollback();
												return res.status(500)
													.json({
														error: true,
														data: { mensaje: err.message }
													});
											});
										})
										.catch(function (err) {
											transaction.rollback();
											return res.status(500)
												.json({
													error: true,
													data: { mensaje: err.message }
												});
										});
									})
									.catch(function (err) {
										transaction.rollback();
										return res.status(500)
											.json({
												error: true,
												data: { mensaje: err.message }
											});
									});
								})
							}
					
						})
						.catch(function (err) {
							return res.status(500)
								.json({
									error: true,
									data: { mensaje: err.message }
								});
						})
					}
				})
				.catch(function (err) {
					return res.status(500)
						.json({
							error: true,
							data: { mensaje: err.message }
						});
				})
			}
		})
		.catch(function(err){ 
			return res.status(500)
				.json({
					error: true,
					data: { mensaje: err.message }
				});
		});

	} 
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

function getMiServicioActivo(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Solicitud_servicios.query(function (qb) {
   		qb.where('solicitud_servicio.estatus', '=', 1);
   		qb.where('id_cliente', '=', id);
	})
	.fetch({ withRelated: [
		'servicio'
		]})
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'dato no encontrado' } 
			});
		var servicios= [];
		for (var i = data.length - 1; i >= 0; i--) {
			servicios.push(data[i]) 
		}
		return res.status(200).json({ 
			error : false, 
			data : data,
			servicios: servicios 
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
	getMiServicioActivo,
	updateSolicitud_servicio,
	deleteSolicitud_servicio
}
