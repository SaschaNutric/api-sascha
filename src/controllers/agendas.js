'use strict';

const Agendas 	= require('../collections/agendas');
const Agenda  	= require('../models/agenda');
const Empleado  = require('../models/empleado');
const VistaAgendas = require('../collections/vista_agendas');
const VistaAgenda = require('../models/vista_agenda');

function getAgendas(req, res, next) {
	Agendas.query(function (qb) {
   		qb.where('agenda.estatus', '=', 1);
	})
	.fetch({ columns: ['id_empleado','id_cliente','id_orden_servicio','id_visita', 'id_cita'] })
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

function getAgendaPorEmpleado(req, res, next) {
	const id_empleado = Number.parseInt(req.params.id_empleado);
	if (!id_empleado || id_empleado == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	if (!req.body.fecha_inicio || !req.body.fecha_fin)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta. Falta fecha_inicio y fecha_fin en el body' }
		});
	VistaAgendas.query(function (qb) {
		qb.where('id_empleado', '=', id_empleado);
		qb.where('fecha', '>=', req.body.fecha_inicio)
		  .andWhere('fecha', '<=', req.body.fecha_fin);
	})
	.fetch()
	.then(function (data) {
		if (!data)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'No hay citas agendadas en el rango de fechas' }
			});
		let agendas = [];
		data.toJSON().map(function (agenda) {
			agendas.push({
				id_agenda:       agenda.id_agenda,
				id_empleado:     agenda.id_empleado,
				nombre_empleado: agenda.nombre_empleado,
				id_cliente:      agenda.id_cliente,
				nombre_cliente:  agenda.nombre_cliente,
				id_servicio:     agenda.id_servicio,
				nombre_servicio: agenda.nombre_servicio,
				id_tipo_cita:    agenda.id_tipo_cita,
				tipo_cita:       agenda.tipo_cita,
				fecha_inicio: 	`${JSON.stringify(agenda.fecha).substr(1,10)}T${agenda.hora_inicio}Z`,
				fecha_fin: 		`${JSON.stringify(agenda.fecha).substr(1, 10)}T${agenda.hora_fin}Z`,
				horario:         JSON.stringify(agenda.hora_inicio).substr(1, 5)
			})
		})
		return res.status(200).json({
			error: false,
			data: agendas
		});
	})
	.catch(function (err) {
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
	});
}

function saveAgenda(req, res, next){
	console.log(JSON.stringify(req.body));

	Agenda.forge({ id_empleado:req.body.id_empleado ,id_cliente:req.body.id_cliente ,id_orden_servicio:req.body.id_orden_servicio ,id_visita:req.body.id_visita ,id_incidencia:req.body.id_incidencia ,id_cita:req.body.id_cita  })
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

function getAgendaById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	VistaAgenda.forge({ id_agenda: id })
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

function updateAgenda(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Agenda.forge({ id_agenda: id })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_empleado:req.body.id_empleado || data.get('id_empleado'),id_cliente:req.body.id_cliente || data.get('id_cliente'),id_orden_servicio:req.body.id_orden_servicio || data.get('id_orden_servicio'),id_visita:req.body.id_visita || data.get('id_visita'),id_incidencia:req.body.id_incidencia || data.get('id_incidencia'),id_cita:req.body.id_cita || data.get('id_cita') })
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

function deleteAgenda(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Agenda.forge({ id_agenda: id })
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
	getAgendas,
	saveAgenda,
	getAgendaById,
	updateAgenda,
	deleteAgenda,
	getAgendaPorEmpleado
}
