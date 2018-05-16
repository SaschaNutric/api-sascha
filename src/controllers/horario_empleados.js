'use strict';

const Horario_empleados = require('../collections/horario_empleados');
const Horario_empleado  = require('../models/horario_empleado');
const Bloques_Horarios    = require('../models/bloque_horario');
const Bluebird          = require('bluebird');

function getHorario_empleados(req, res, next) {
	Horario_empleados.query(function (qb) {
   		qb.where('horario_empleado.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'bloque_horario',
			'dia_laborable'
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

function saveHorario_empleado(req, res, next){
	Bluebird.map(req.body.bloques_horarios, function(horario) {
		Horario_empleado.forge({
			id_empleado: req.body.id_empleado,
			id_bloque_horario: horario.id_bloque_horario,
			id_dia_laborable: req.body.id_dia_laborable  
		})
		.save()
	})
	.then(function(next) {
		Horario_empleados.forge({ id_empleado: req.body.id_empleado })
			.fetch()
			.then(function (bloque) {
				console.log(bloque);
				horarios.push(bloque.toJSON());
				console.log(horarios);
			})
			.catch(function(err) {
				return res.status(500).json({ 
					error: true,
					data: { mensaje: err.message }
				})
			})
		})
		.then(function(data) {
			res.status(200).json({
			id_empleado: req.body.id_empleado,
			id_dia_laborable: req.body.id_dia_laborable,
			bloques_horarios: horarios
			});
		})
		.catch(function(err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			})
		})
	})
	.catch(function(err) {
		res.status(500).json({
			error: true,
			data: { message: err.message }
		});
	});
}

function getHorario_empleadoById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Horario_empleados.query(function (qb) {
   		qb.where('horario_empleado.estatus', '=', 1);
   		qb.where('id_horario_empleado.estatus', '=', id);
	})
	.fetch({
		withRelated: [
			'empleado',
			'bloque_horario',
			'dia_laborable'
		] })
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
	updateHorario_empleado,
	deleteHorario_empleado
}
