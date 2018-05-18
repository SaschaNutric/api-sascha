'use strict';

const Horario_empleados = require('../collections/horario_empleados');
const Horario_empleado  = require('../models/horario_empleado');
const Bloques_Horarios    = require('../models/bloque_horario');
const Bluebird          = require('bluebird');

function getHorario_empleados(req, res, next) {
	Horario_empleados.query(function(qb) {
		qb.where('estatus', '=', 1); 
	})
	.fetch({ withRelated: ['empleado', 'dia_laborable', 'bloque_horario'] })
	.then(function(data) {
		let nuevaData = data.toJSON();
		let empleados = [];
		nuevaData.map(function(registro) {
			let index = empleados.map(function (empleado) {
											return empleado.id_empleado;
										})
										.indexOf(registro.id_empleado);
			if (index == -1) {
				empleados.push({
					id_empleado: registro.empleado.id_empleado,
					nombre: `${registro.empleado.nombres} ${registro.empleado.apellidos}`,
					dias_laborables: [{ 
						id_dia_laborable: registro.dia_laborable.id_dia_laborable,
						dia: registro.dia_laborable.dia,
						bloques_horarios: [{
							id_bloque_horario: registro.bloque_horario.id_bloque_horario,
							hora_inicio: registro.bloque_horario.hora_inicio
						}]
					}]
				})
			}
			else {
				let diaIndex = empleados[index].dias_laborables.map(function (dia) {
													return dia.id_dia_laborable;
												})
												.indexOf(registro.id_dia_laborable);
				if(diaIndex == -1) {
					empleados[index].dias_laborables.push({
						id_dia_laborable: registro.dia_laborable.id_dia_laborable,
						dia: registro.dia_laborable.dia,
						bloques_horarios: [{
							id_bloque_horario: registro.bloque_horario.id_bloque_horario,
							hora_inicio: registro.bloque_horario.hora_inicio
						}]
					})
				}
				else {
					empleados[index].dias_laborables[diaIndex].bloques_horarios.push({
						id_bloque_horario: registro.bloque_horario.id_bloque_horario,
						hora_inicio: registro.bloque_horario.hora_inicio
					})
				}
			}
		});

		res.status(200).json({
			error: false,
			data: empleados
		});
	})
	.catch(function(err) {
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		})
	})
}

function saveHorario_empleado(req, res, next) {
	Horario_empleados.query(function(qb) {
		qb.where('id_empleado', '=', req.body.id_empleado)
		  .andWhere('id_dia_laborable', '=', req.body.id_dia_laborable)
		  .delete();
	})
	.fetch()
	.then(function(nose) {
		Bluebird.map(req.body.bloques_horarios, function(horario) {
			Horario_empleado.forge({
				id_empleado: req.body.id_empleado,
				id_bloque_horario: horario.id_bloque_horario,
				id_dia_laborable: req.body.id_dia_laborable  
			})
			.save()
		})
		.then(function(datos) {
			Horario_empleados.query(function(qb) {
				qb.where('id_empleado', '=', req.body.id_empleado)
				qb.where('id_dia_laborable', '=', req.body.id_dia_laborable)
				qb.where('estatus', '=', 1); 
			})
			.fetch({ withRelated: ['empleado', 'dia_laborable', 'bloque_horario'] })
			.then(function(data) {
				let nuevaData = data.toJSON();
				console.log(nuevaData[0])
				let bloques = [];				
				nuevaData.map(function(horario) {
					bloques.push({ 
						id_bloque_horario: horario.bloque_horario.id_bloque_horario, 
						hora_inicio: JSON.stringify(horario.bloque_horario.hora_inicio).substr(1,5)
					})
				})
	
				let empleadoHorario = {
					empleado: {
						id_empleado: nuevaData[0].empleado.id_empleado,
						nombre_completo: `${nuevaData[0].empleado.nombres} ${nuevaData[0].empleado.apellidos}`,
					},
					dia_laborable: {
						id_dia_laborable: nuevaData[0].dia_laborable.id_dia_laborable,
						dia: nuevaData[0].dia_laborable.dia
					},
					bloques_horarios: bloques
				}	
	
				res.status(200).json({
					error: false,
					data: empleadoHorario
				});
			})
			.catch(function(err) {
				return res.status(500).json({
					error: true,
					data: { mensaje: err.message }
				})
			})
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			})
		})
	})
	.catch(function (err) {
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		})
	})
}

function getHorario_empleadoById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Horario_empleados.query(function (qb) {
		qb.where('id_empleado', '=', id);
   		qb.where('horario_empleado.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'empleado',
			'bloque_horario',
			'dia_laborable'
		] })
	.then(function(data) {
		let nuevaData = data.toJSON();
		if (nuevaData.length == 0)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'No hay datos registrados' }
			});

		let dias = []
		nuevaData.map(function(registro) {
			let diaIndex = dias.map(function (dia) {
									return dia.id_dia_laborable;
								})
								.indexOf(registro.id_dia_laborable);
			if(diaIndex == -1) {
				dias.push({
					id_dia_laborable: registro.dia_laborable.id_dia_laborable,
					dia: registro.dia_laborable.dia,
					bloques_horarios: [{
						id_bloque_horario: registro.bloque_horario.id_bloque_horario,
						hora_inicio: registro.bloque_horario.hora_inicio
					}]
				})
			}
			else {
				dias[diaIndex].bloques_horarios.push({
					id_bloque_horario: registro.bloque_horario.id_bloque_horario,
					hora_inicio: registro.bloque_horario.hora_inicio
				})
			}
		});
		let empleado = {
			id_empleado: nuevaData[0].empleado.id_empleado,
			nombre: `${nuevaData[0].empleado.nombres} ${nuevaData[0].empleado.apellidos}`,
			dias_laborables: dias 
		}
		return res.status(200).json({
			error: false,
			data: empleado
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}


function getHorariByEmpleadoAndDia(req, res, next) {
	if (!req.body.id_empleado || !req.body.id_dia_laborable)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida. Faltan campos en el body' }
		})

	Horario_empleados.query(function (qb) {
		qb.where('horario_empleado.id_empleado', '=', req.body.id_empleado);
		qb.where('horario_empleado.id_dia_laborable', '=', req.body.id_dia_laborable)
		qb.where('horario_empleado.estatus', '=', 1);
	})
		.fetch({
			withRelated: [
				'empleado',
				'bloque_horario',
				'dia_laborable'
			]
		})
		.then(function (data) {
			let nuevaData = data.toJSON();
			if (nuevaData.length == 0)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay datos registrados' }
				});

			let bloques = []
			nuevaData.map(function (registro) {
				bloques.push({
					id_bloque_horario: registro.bloque_horario.id_bloque_horario,
					hora_inicio: registro.bloque_horario.hora_inicio,
					hora_fin: registro.bloque_horario.hora_fin
				})
				
			})
			
			return res.status(200).json({
				error: false,
				data: { bloques_horarios: bloques }
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}

function updateHorario_empleado(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Horario_empleado.forge({ id_horario_empleado: id })
	.fetch({
		withRelated: [
			'empleado',
			'bloque_horario',
			'dia_laborable'
		] })
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_empleado:req.body.id_empleado || data.get('id_empleado'),id_bloque_horario:req.body.id_bloque_horario || data.get('id_bloque_horario'),id_dia_laborable:req.body.id_dia_laborable || data.get('id_dia_laborable') })
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

function deleteHorario_empleado(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Horario_empleado.forge({ id_horario_empleado: id })
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
	getHorario_empleados,
	saveHorario_empleado,
	getHorario_empleadoById,
	getHorariByEmpleadoAndDia,
	updateHorario_empleado,
	deleteHorario_empleado
}
