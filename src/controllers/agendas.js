'use strict';

const Agendas 	= require('../collections/agendas');
const Agenda  	= require('../models/agenda');
const Empleado  = require('../models/empleado');
const VistaAgendas = require('../collections/vista_agendas');
const VistaAgenda = require('../models/vista_agenda');

function getAgendas(req, res, next) {
	VistaAgendas.query(function (qb) {
   		qb.where('agenda.estatus', '=', 1);
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

function getProximaCitaPorCliente(req, res, next) {
	const id_cliente = Number.parseInt(req.params.id_cliente);
	if (!id_cliente || id_cliente == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});

	VistaAgendas.query(function (qb) {
		qb.where('id_cliente', '=', id_cliente);
		qb.whereRaw('id_visita is null');
		qb.orderByRaw('fecha ASC');
	})
		.fetch()
		.then(function (data) {
			let data_json = data.toJSON()
			if (data_json.length == 0)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay proxima cita agendada para el cliente' }
				});
			
			let agenda = data_json[0];
			
			let nuevaAgenda = {
				id_agenda: agenda.id_agenda,
				id_visita: agenda.id_visita,
				id_empleado: agenda.id_empleado,
				nombre_empleado: agenda.nombre_empleado,
				id_cliente: agenda.id_cliente,
				nombre_cliente: agenda.nombre_cliente,
				id_servicio: agenda.id_servicio,
				nombre_servicio: agenda.nombre_servicio,
				id_cita: agenda.id_cita,
				id_tipo_cita: agenda.id_tipo_cita,
				tipo_cita: agenda.tipo_cita,
				fecha: JSON.stringify(agenda.fecha).substr(1, 10),
				hora_inicio: JSON.stringify(agenda.hora_inicio).substr(1, 5),
				hora_fin: JSON.stringify(agenda.hora_fin).substr(1, 5)
			}
			
			return res.status(200).json({
				error: false,
				data: nuevaAgenda
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
				id_visita:       agenda.id_visita,
				id_empleado:     agenda.id_empleado,
				nombre_empleado: agenda.nombre_empleado,
				id_cliente:      agenda.id_cliente,
				nombre_cliente:  agenda.nombre_cliente,
				id_servicio:     agenda.id_servicio,
				nombre_servicio: agenda.nombre_servicio,
				id_cita:         agenda.id_cita,           
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
			'regimen_dieta',
			'regimen_dieta.alimentos',
			'regimen_dieta.detalle',		
			'regimen_suplemento',
			'regimen_suplemento.suplemento',
			'regimen_ejercicio',
			'regimen_ejercicio.ejercicio',
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
			if (JSON.stringify(meta.parametro) != '{}') {
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
			}
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
				unidad: parametro.parametro.unidad ? parametro.parametro.unidad.nombre : null ,
				unidad_abreviatura: parametro.parametro.unidad ? parametro.parametro.unidad.abreviatura : null
			});
		});
		let comidasPlanDieta = [];
		agenda.servicio.plan_dieta.detalle.map(function (comida) {
			let index = comidasPlanDieta.map(function (comidaAsignada) {
											return comidaAsignada.id_comida;
										})
										.indexOf(comida.id_comida);
			if (index == -1) {	
				let regimenIndex = agenda.regimen_dieta.map(function (regimen) {
					return regimen.id_detalle_plan_dieta 
				})
				.indexOf(comida.id_detalle_plan_dieta); 
				
				if (regimenIndex == -1) {
					comidasPlanDieta.push({
						id_comida: comida.comida.id_comida,
						nombre: comida.comida.nombre,
						grupos_alimenticios: [{
							id_detalle_plan_dieta: comida.id_detalle_plan_dieta,
							id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
							nombre: comida.grupoAlimenticio.nombre,
							//cantidad: regimen.cantidad,
							//alimentos: alimentos,
							unidad: comida.grupoAlimenticio.unidad.nombre,
							unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
						}]
					})
				}
				else {
					let alimentos = [];
					agenda.regimen_dieta[regimenIndex].alimentos.map(function (alimento) {
						alimentos.push({
							id_alimento: alimento.id_alimento,
							nombre: alimento.nombre
						})
					})
					comidasPlanDieta.push({
						id_comida: comida.comida.id_comida,
						nombre: comida.comida.nombre,
						grupos_alimenticios: [{
							id_detalle_plan_dieta: comida.id_detalle_plan_dieta,
							id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
							nombre: comida.grupoAlimenticio.nombre,
							id_regimen_dieta: agenda.regimen_dieta[regimenIndex].id_regimen_dieta,
							cantidad: agenda.regimen_dieta[regimenIndex].cantidad,
							alimentos: alimentos,
							unidad: comida.grupoAlimenticio.unidad.nombre,
							unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
						}]
					})
				}
			}
			else {
				let regimenIndex = agenda.regimen_dieta.map(function (regimen) {
					return regimen.id_detalle_plan_dieta
				})
				.indexOf(comida.id_detalle_plan_dieta);

				if (regimenIndex == -1) { 
					comidasPlanDieta[index].grupos_alimenticios.push({
						id_detalle_plan_dieta: comida.id_detalle_plan_dieta,
						id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
						nombre: comida.grupoAlimenticio.nombre,
						//cantidad: regimen.cantidad,
						//alimentos: alimentos,
						unidad: comida.grupoAlimenticio.unidad.nombre,
						unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
					})
				}
				else {
					let alimentos = [];
					agenda.regimen_dieta[regimenIndex].alimentos.map(function (alimento) {
						alimentos.push({
							id_alimento: alimento.id_alimento,
							nombre: alimento.nombre
						})
					});
					comidasPlanDieta[index].grupos_alimenticios.push({
						id_detalle_plan_dieta: comida.id_detalle_plan_dieta,
						id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
						nombre: comida.grupoAlimenticio.nombre,
						id_regimen_dieta: agenda.regimen_dieta[regimenIndex].id_regimen_dieta, 
						cantidad: agenda.regimen_dieta[regimenIndex].cantidad,
						alimentos: alimentos,
						unidad: comida.grupoAlimenticio.unidad.nombre,
						unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
					})
				}
			}
		})

		let ejercicios = [];
		agenda.servicio.plan_ejercicio.ejercicios.map(function(ejercicio) {
			let ejercicioIndex = agenda.regimen_ejercicio.map(function(regimen) {
				return regimen.id_ejercicio
			})
			.indexOf(ejercicio.id_ejercicio);
			
			if(ejercicioIndex == -1) {
				ejercicios.push({
					id_ejercicio: ejercicio.id_ejercicio,
					//id_tiempo: regimen.id_tiempo,
					//duracion: regimen.duracion,
					nombre: ejercicio.nombre
				})
			}
			else {
				ejercicios.push({
					id_ejercicio: ejercicio.id_ejercicio,
					id_regimen_ejercicio: agenda.regimen_ejercicio[ejercicioIndex].id_regimen_ejercicio,
					id_tiempo: agenda.regimen_ejercicio[ejercicioIndex].id_tiempo,
					id_frecuencia: agenda.regimen_ejercicio[ejercicioIndex].id_frecuencia,					
					duracion: agenda.regimen_ejercicio[ejercicioIndex].duracion,
					nombre: ejercicio.nombre
				});
			}
		});
		let suplementos = [];
		agenda.servicio.plan_suplemento.suplementos.map(function (suplemento) {
			let suplementoIndex = agenda.regimen_suplemento.map(function (regimen) {
				return regimen.id_suplemento
			})
			.indexOf(suplemento.id_suplemento);
			
			if(suplementoIndex == -1) {
				suplementos.push({
					id_suplemento: suplemento.id_suplemento,
					nombre: suplemento.nombre,
					//frecuencia: regimen.id_frecuencia,
					//cantidad: regimen.cantidad,
					unidad: suplemento.unidad.nombre,
					unidad_abreviatura: suplemento.unidad.abreviatura
				})
			}
			else {
				suplementos.push({
					id_suplemento: suplemento.id_suplemento,
					nombre: suplemento.nombre,
					id_regimen_suplemento: agenda.regimen_suplemento[suplementoIndex].id_regimen_suplemento, 
					frecuencia: agenda.regimen_suplemento[suplementoIndex].id_frecuencia,
					cantidad: agenda.regimen_suplemento[suplementoIndex].cantidad,
					unidad: suplemento.unidad.nombre,
					unidad_abreviatura: suplemento.unidad.abreviatura
				})
			}
		});
		let nuevaAgenda = {
			id_agenda:    agenda.id_agenda,
			id_visita:    agenda.id_visita,
			id_cita:      agenda.id_cita,
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
					plan_ejercicio: agenda.servicio.plan_ejercicio? {
						id_plan_ejercicio: agenda.servicio.plan_ejercicio.id_plan_ejercicio,
						nombre: agenda.servicio.plan_ejercicio.nombre,
						ejercicios: ejercicios
					}:null,
					plan_suplemento: agenda.servicio.plan_suplemento?{
						id_plan_suplemento: agenda.servicio.plan_suplemento.id_plan_suplemento,
						nombre: agenda.servicio.plan_suplemento.nombre,
						suplementos: suplementos
					}:null
				}
			}
		}

		return res.status(200).json({ 
			error: false, 
			data:  nuevaAgenda 
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}


function getPlanPorCliente(req, res, next) {
	const id = Number.parseInt(req.params.id_cliente);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	VistaAgendas.query(function (qb) {
		qb.where('id_cliente', '=', id);
		qb.orderBy('fecha_creacion','ASC'); 
	})
	.fetch({
		withRelated: [
			'regimen_dieta',
			'regimen_dieta.alimentos',
			'regimen_dieta.detalle',		
			'regimen_suplemento',
			'regimen_suplemento.suplemento',
			'regimen_ejercicio',
			'regimen_ejercicio.ejercicio',
			'regimen_ejercicio.tiempo',
			'regimen_ejercicio.frecuencia',
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
		let agendas = data.toJSON();
		let visitas_realizadas = [];
		
		let agenda = agendas[0];
		let comidasPlanDieta = [];
		agenda.servicio.plan_dieta.detalle.map(function (comida) {
			let index = comidasPlanDieta.map(function (comidaAsignada) {
				return comidaAsignada.id_comida;
			})
			.indexOf(comida.id_comida);
			if (index == -1) {	
				let regimenIndex = agenda.regimen_dieta.map(function (regimen) {
					return regimen.id_detalle_plan_dieta 
				})
				.indexOf(comida.id_detalle_plan_dieta); 

				let grupoAlimenticios = [];
				
				if (JSON.stringify(comida.grupoAlimenticio) != '{}') {
					grupoAlimenticios = [{
							id_detalle_plan_dieta: comida.id_detalle_plan_dieta,
							id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
							nombre: comida.grupoAlimenticio.nombre,
							//cantidad: regimen.cantidad,
							//alimentos: alimentos,
							unidad: comida.grupoAlimenticio.unidad.nombre,
							unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
						}];
				}

				if (regimenIndex == -1) {
					comidasPlanDieta.push({
						id_comida: comida.comida.id_comida,
						nombre: comida.comida.nombre,
						grupos_alimenticios: []
					})
				}
				else {
					let alimentos = [];
					agenda.regimen_dieta[regimenIndex].alimentos.map(function (alimento) {
						alimentos.push({
							id_alimento: alimento.id_alimento,
							nombre: alimento.nombre
						})
					})
					comidasPlanDieta.push({
						id_comida: comida.comida.id_comida,
						nombre: comida.comida.nombre,
						grupos_alimenticios: comida.grupoAlimenticio? [{
							id_detalle_plan_dieta: comida.id_detalle_plan_dieta,
							id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
							nombre: comida.grupoAlimenticio.nombre,
							cantidad: agenda.regimen_dieta[regimenIndex].cantidad,
							alimentos: alimentos,
							unidad: comida.grupoAlimenticio.unidad.nombre,
							unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
						}]: []
					})
				}
			}
			else {
				let regimenIndex = agenda.regimen_dieta.map(function (regimen) {
					return regimen.id_detalle_plan_dieta
				})
				.indexOf(comida.id_detalle_plan_dieta);

				if (regimenIndex == -1) { 
					comidasPlanDieta[index].grupos_alimenticios = []
				}
				else {
					let alimentos = [];
					agenda.regimen_dieta[regimenIndex].alimentos.map(function (alimento) {
						alimentos.push({
							id_alimento: alimento.id_alimento,
							nombre: alimento.nombre
						})
					});
					comidasPlanDieta[index].grupos_alimenticios.push({
						id_detalle_plan_dieta: comida.id_detalle_plan_dieta,
						id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
						nombre: comida.grupoAlimenticio.nombre,
						cantidad: agenda.regimen_dieta[regimenIndex].cantidad,
						alimentos: alimentos,
						unidad: comida.grupoAlimenticio.unidad.nombre,
						unidad_abreviatura: comida.grupoAlimenticio.unidad.abreviatura
					})
				}
			}
		})

		let ejercicios = [];
		agenda.servicio.plan_ejercicio.ejercicios.map(function(ejercicio) {
			let ejercicioIndex = agenda.regimen_ejercicio.map(function(regimen) {
				return regimen.id_ejercicio
			})
			.indexOf(ejercicio.id_ejercicio);
			
			if(ejercicioIndex != -1) {
				ejercicios.push({
					id_ejercicio: ejercicio.id_ejercicio,
					nombre: ejercicio.nombre,
					descripcion: ejercicio.descripcion,
					duracion: agenda.regimen_ejercicio[ejercicioIndex].duracion,
					id_tiempo: agenda.regimen_ejercicio[ejercicioIndex].id_tiempo,
					tiempo: agenda.regimen_ejercicio[ejercicioIndex].tiempo.nombre,
					tiempo_abreviatura: agenda.regimen_ejercicio[ejercicioIndex].tiempo.abreviatura,
					id_frecuencia: agenda.regimen_ejercicio[ejercicioIndex].id_frecuencia,
					frecuencia: agenda.regimen_ejercicio[ejercicioIndex].frecuencia.frecuencia				
				});
			}
		});
		let suplementos = [];
		agenda.servicio.plan_suplemento.suplementos.map(function (suplemento) {
			let suplementoIndex = agenda.regimen_suplemento.map(function (regimen) {
				return regimen.id_suplemento
			})
			.indexOf(suplemento.id_suplemento);
			
			if(suplementoIndex != -1) {
				suplementos.push({
					id_suplemento: suplemento.id_suplemento,
					nombre: suplemento.nombre,
					id_frecuencia: agenda.regimen_suplemento[suplementoIndex].id_frecuencia,
					frecuencia: agenda.regimen_suplemento[suplementoIndex].id_frecuencia,
					cantidad: agenda.regimen_suplemento[suplementoIndex].cantidad,
					unidad: suplemento.unidad.nombre,
					unidad_abreviatura: suplemento.unidad.abreviatura
				})
			}
			
		});
		let nuevaAgenda = {
			id_agenda:    agenda.id_agenda,
			id_visita:    agenda.id_visita,
			id_tipo_cita: agenda.id_tipo_cita,
			tipo_cita:    agenda.tipo_cita,
			fecha:       JSON.stringify(agenda.fecha).substr(1,10),
			hora_inicio: JSON.stringify(agenda.hora_inicio).substr(1,5),
			hora_fin:    JSON.stringify(agenda.hora_fin).substr(1,5),
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
				plan_ejercicio: agenda.servicio.plan_ejercicio? {
					id_plan_ejercicio: agenda.servicio.plan_ejercicio.id_plan_ejercicio,
					nombre: agenda.servicio.plan_ejercicio.nombre,
					ejercicios: ejercicios
				}:null,
				plan_suplemento: agenda.servicio.plan_suplemento?{
					id_plan_suplemento: agenda.servicio.plan_suplemento.id_plan_suplemento,
					nombre: agenda.servicio.plan_suplemento.nombre,
					suplementos: suplementos
				}:null
			}
		}

		return res.status(200).json({ 
			error: false, 
			data: nuevaAgenda
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}


function getMiServicios(req, res, next) {
	const id = Number.parseInt(req.params.id_cliente);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	VistaAgendas.query(function (qb) {
		qb.where('id_cliente', '=', id);
		qb.orderBy('fecha_creacion','ASC'); 
	})
	.fetch({
		withRelated: [
			'orden',
			'servicio',
			'servicio.plan_dieta',
			'servicio.plan_ejercicio',
			'servicio.plan_suplemento',
			'servicio.especialidad',
			'servicio.parametros',
			'servicio.parametros.parametro',
			'servicio.condiciones_garantia'
		]
	})
	.then(function(data) {
		if (!data)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'Agenda no encontrada' }
			});
		let agendas = data.toJSON();
		let servicios = [];
		
		for (var i = agendas.length - 1; i >= 0; i--) {
			let agenda = agendas[i];
			servicios.push({
				"servicio": agenda.servicio,
				"estado": agenda.orden.estado
			});
		}
		
		return res.status(200).json({ 
			error: false, 
			data: servicios
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function getMiOrdenServicios(req, res, next) {
	const id = Number.parseInt(req.params.id_cliente);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	VistaAgendas.query(function (qb) {
		qb.where('id_cliente', '=', id);
		qb.orderBy('fecha_creacion','ASC'); 
	})
	.fetch()
	.then(function(data) {
		if (!data)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'Agenda no encontrada' }
			});
		let agendas = data.toJSON();
		let orden_servicios = [];
		
		for (var i = agendas.length - 1; i >= 0; i--) {
			let agenda = agendas[i];
			orden_servicios.push(agenda.id_orden_servicio);
		}
		
		return res.status(200).json({ 
			error: false, 
			data: orden_servicios
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
	getPlanPorCliente,
	getMiOrdenServicios,
	getMiServicios,
	updateAgenda,
	deleteAgenda,
	getAgendaPorEmpleado,
	getProximaCitaPorCliente
}
