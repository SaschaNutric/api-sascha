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
	.fetch({
		withRelated: [
			'perfil',
			'perfil.parametro',
			'perfil.parametro.tipo_parametro',			
			'perfil.parametro.unidad',
			'metas',
			'metas.parametro',
			'metas.parametro.tipo_parametro',			
			'metas.parametro.unidad',
			'servicio',
			'servicio.plan_dieta',
			'servicio.plan_dieta.tipo_dieta',
			'servicio.plan_dieta.detalle.comida',
			'servicio.plan_dieta.detalle.grupoAlimenticio',
			'servicio.plan_dieta.detalle.grupoAlimenticio.unidad',			
			'servicio.plan_ejercicio',
			'servicio.plan_ejercicio.ejercicios',
			'servicio.plan_suplemento',
			'servicio.plan_suplemento.suplementos',
			'servicio.plan_suplemento.suplementos.unidad',
			'servicio.especialidad',
		]
	})
	.then(function(data) {
		if (!data)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'Agenda no encontrada' }
			});

		let agenda = data.toJSON();
		let metas = [];
		agenda.metas.map(function(meta) {
			metas.push({
				id_parametro_meta: meta.id_parametro_meta,
				id_parametro: meta.id_parametro,
				parametro: meta.parametro.nombre,
				valor_minimo: meta.valor_minimo,
				valor_maximo: meta.valor_maximo,
				tipo_parametro: meta.parametro.tipo_parametro.nombre,
				unidad: meta.parametro.unidad.nombre,
				unidad_abreviatura: meta.parametro.unidad.abreviatura
			});
		});
		let perfil = [];
		agenda.perfil.map(function(parametro) {
			if(parametro.parametro.estatus ==1)
			perfil.push({
				id_parametro_cliente: parametro.id_parametro_cliente,
				id_parametro: parametro.id_parametro,
				parametro: parametro.parametro.nombre,
				valor: parametro.valor,
				tipo_valor: parametro.parametro.tipo_valor,
				tipo_parametro: parametro.parametro.tipo_parametro.nombre,
				unidad: parametro.parametro.unidad.nombre,
				unidad_abreviatura: parametro.parametro.unidad.abreviatura
			});
		});
		let comidasPlanDieta = [];
		agenda.servicio.plan_dieta.detalle.map(function (comida) {
			let index = comidasPlanDieta.map(function (comidaAsignada) {
											return comidaAsignada.id_comida;
										})
										.indexOf(comida.id_comida);
			if (index == -1) {
				comidasPlanDieta.push({
					id_comida: comida.comida.id_comida,
					nombre: comida.comida.nombre,
					grupos_alimenticios: [{
						id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
						nombre: comida.grupoAlimenticio.nombre,
						unidad: comida.grupoAlimenticio.unidad.nombre,
						unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
					}]
				})
			}
			else {
				comidasPlanDieta[index].grupos_alimenticios.push({
					id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
					nombre: comida.grupoAlimenticio.nombre,
					unidad: comida.grupoAlimenticio.unidad.nombre,
					unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
				})
			}
		})
		let ejercicios = [];
		agenda.servicio.plan_ejercicio.ejercicios.map(function(ejercicio) {
			ejercicios.push({
				id_ejercicio: ejercicio.id_ejercicio,
				nombre: ejercicio.nombre
			})
		});
		let suplementos = [];
		agenda.servicio.plan_suplemento.suplementos.map(function (suplemento) {
			suplementos.push({
				id_suplemento: suplemento.id_suplemento,
				nombre: suplemento.nombre,
				unidad: suplemento.unidad.nombre,
				unidad_abreviatura: suplemento.unidad.abreviatura
			})
		});
		let nuevaAgenda = {
			id_agenda:    agenda.id_agenda,
			id_tipo_cita: agenda.id_tipo_cita,
			tipo_cita:    agenda.tipo_cita,
			fecha:       JSON.stringify(agenda.fecha).substr(1,10),
			hora_inicio: JSON.stringify(agenda.hora_inicio).substr(1,5),
			hora_fin:    JSON.stringify(agenda.hora_fin).substr(1,5),
			cliente: {
				id_cliente: agenda.id_cliente,
				nombre_completo: agenda.nombre_cliente,
				direccion: agenda.direccion_cliente,
				telefono: agenda.telefono_cliente,
				edad: agenda.edad_cliente,
				fecha_nacimiento: JSON.stringify(agenda.fecha_nacimiento_cliente).substr(1,10),
				perfil: perfil
			},
			orden_servicio: {
				id_orden_servicio: agenda.id_orden_servicio,
				visitas_realizadas: agenda.visitas_realizadas,
				metas: metas,
				servicio: {
					id_servicio: agenda.id_servicio,
					nombre: agenda.nombre_servicio,
					numero_visitas: agenda.duracion_servicio,
					especialidad: agenda.servicio.especialidad.nombre,
					plan_dieta: {
						id_plan_dieta: agenda.servicio.plan_dieta.id_plan_dieta,
						nombre: agenda.servicio.plan_dieta.nombre,
						tipo_dieta: agenda.servicio.plan_dieta.tipo_dieta.nombre,
						comidas: comidasPlanDieta
					},
					plan_ejercicio: {
						id_plan_ejercicio: agenda.servicio.plan_ejercicio.id_plan_ejercicio,
						nombre: agenda.servicio.plan_ejercicio.nombre,
						ejercicios: ejercicios
					},
					plan_suplemento: {
						id_plan_suplemento: agenda.servicio.plan_suplemento.id_plan_suplemento,
						nombre: agenda.servicio.plan_suplemento.nombre,
						suplementos: suplementos
					}
				}
			}
		}

		return res.status(200).json({ 
			error : false, 
			data : nuevaAgenda 
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
