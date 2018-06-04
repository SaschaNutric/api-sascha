'use strict';

const Calificaciones = require('../collections/calificaciones');
const Calificacion   = require('../models/calificacion');
const OrdenServicio  = require('../models/orden_servicio');
const Bookshelf      = require('../commons/bookshelf');
const VistaCalificacionServicios = require('../collections/vista_calificacion_servicios');
const VistaCalificaionServicio = require('../models/vista_calificacion_servicio');
const VistaCalificacionVisitas = require('../collections/vista_calificacion_visitas');
const VistaCalificacionVisita = require('../models/vista_calificacion_visita');

function getCalificaciones(req, res, next) {
	Calificaciones.query(function (qb) {
   		qb.where('calificacion.estatus', '=', 1);
	})
	.fetch({ columns: ['id_calificacion','id_criterio','id_visita','id_orden_servicio'] })
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

function getCalificacionDashboard(req, res, next) {
	VistaCalificacionServicios.query(function (qb) {
		qb.where('id_tipo_criterio', '=', 1);
	})
	.fetch()
	.then(function (data){
		if (!data)
		return res.status(404).json({
			error: true,
			data: { mensaje: 'No hay citas agendadas en el rango de fechas' }
		});
		let ponderacion = 0;
		let totalCalificaciones = data.length;
		data.toJSON().map(function (calificacion){
			ponderacion = ponderacion + calificacion.ponderacion;
		})
		let promedio = (ponderacion/totalCalificaciones); 
		let calificacion = {
			ponderacion: ponderacion,
			total_calificaciones: totalCalificaciones,
			promedio: promedio
		}
		
		return res.status(200).json({
			error: false,
			data: calificacion
		});
	})
	.catch(function (err) {
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
	});
}

function getCalificacionDashboardEmpleado(req, res, next) {
	const id_empleado = Number.parseInt(req.params.id_empleado);
	if (!id_empleado || id_empleado == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	VistaCalificacionVisitas.query(function (qb) {
		qb.where('id_empleado', '=', id_empleado);
	})
	.fetch()
	.then(function (data){
		if (!data)
		return res.status(404).json({
			error: true,
			data: { mensaje: 'No hay citas agendadas en el rango de fechas' }
		});
		let ponderacion = 0;
		let totalCalificaciones = data.length;
		data.toJSON().map(function (calificacion){
			ponderacion = ponderacion + calificacion.ponderacion;
		})
		let promedio = (ponderacion/totalCalificaciones); 
		let calificacion = {
			ponderacion: ponderacion,
			total_calificaciones: totalCalificaciones,
			promedio: promedio
		}
		
		return res.status(200).json({
			error: false,
			data: calificacion
		});
	})
	.catch(function (err) {
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
	});
}

function saveCalificacion(req, res, next){
	console.log(JSON.stringify(req.body));

	Calificacion.forge({ 
		id_criterio:req.body.id_criterio ,
		id_visita:req.body.id_visita ,
		id_orden_servicio:req.body.id_orden_servicio  
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

function saveCalificacionesVisita(req, res, next) {
	console.log(JSON.stringify(req.body));
	let id = Number.parseInt(req.params.id);
	if (id == 'NaN' || !req.body.calificaciones || !req.body.calificaciones.length) {
		res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		})
	}
	Bookshelf.transaction(function (t) {
		let calificaciones = [];
		req.body.calificaciones.map(function (calificacion) {
			calificaciones.push({
				id_visita: id,
				id_criterio: calificacion.id_criterio,
				id_valoracion: calificacion.id_valoracion
			})
		})
		Calificaciones.forge(calificaciones)
		.invokeThen('save', null, { transacting: t })
			.then(function (data) {
				t.commit()
				res.status(200).json({
					error: false,
					data: { mensaje: 'Calificaciones registradas satisfactoriamente' }
				});
			})
			.catch(function (err) {
				t.rollback();
				res.status(500).json({
					error: true,
					data: { message: err.message }
				});
			});
	})
	.catch(function (err) {
		res.status(500).json({
			error: true,
			data: { message: err.message }
		});
	});
}

function saveCalificacionesOrdenServicio(req, res, next) {
	console.log(JSON.stringify(req.body));
	let id = Number.parseInt(req.params.id);
	if(id == 'NaN' || !req.body.calificaciones || !req.body.calificaciones.length) {
		res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		})
	}
	Bookshelf.transaction(function(t) {
		let calificaciones = [];
		req.body.calificaciones.map(function (calificacion) {
			calificaciones.push({
				id_orden_servicio: id,
				id_criterio: calificacion.id_criterio,
				id_valoracion: calificacion.id_valoracion
			})
		})
		Calificaciones.forge(calificaciones)
		.invokeThen('save', null, { transacting: t })
		.then(function (data) {
			OrdenServicio.forge({ id_orden_servicio: id })
			.fetch()
			.then(function (orden) {
				orden.save({ estado: 3 }, { transacting: t })
				.then(function (orden) {
					t.commit()
					res.status(200).json({
						error: false,
						data: { mensaje: 'Calificaciones registradas satisfactoriamente' }
					});
				})
				.catch(function (err) {
					t.rollback()
					return res.status(500).json({
						error: false,
						data: { mensaje: err.message }
					})
				})
			})
			.catch(function (err) {
				t.rollback()
				return res.status(500).json({
					error: false,
					data: { mensaje: err.message }
				})
			})
		})
		.catch(function (err) {
			t.rollback();
			res.status(500).json({
				error: true,
				data: { message: err.message }
			});
		});
	})
	.catch(function (err) {
		res.status(500).json({
			error: true,
			data: { message: err.message }
		});
	});
}

function getCalificacionById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Calificacion.forge({ id_calificacion: id })
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

function updateCalificacion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Calificacion.forge({ id_calificacion: id })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
		 id_criterio:req.body.id_criterio || data.get('id_criterio'),
		 id_visita:req.body.id_visita || data.get('id_visita'),
		 id_orden_servicio:req.body.id_orden_servicio || data.get('id_orden_servicio') 
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

function deleteCalificacion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Calificacion.forge({ id_calificacion: id })
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
	getCalificaciones,
	saveCalificacion,
	saveCalificacionesVisita,
	saveCalificacionesOrdenServicio,	
	getCalificacionById,
	getCalificacionDashboard,
	getCalificacionDashboardEmpleado,	
	updateCalificacion,
	deleteCalificacion
}
