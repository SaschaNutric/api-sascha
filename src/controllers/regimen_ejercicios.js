'use strict';

const Regimen_ejercicios 	= require('../collections/regimen_ejercicios');
const Regimen_ejercicio  	= require('../models/regimen_ejercicio');

function getRegimen_ejercicios(req, res, next) {
	Regimen_ejercicios.query(function (qb) {
   		qb.where('regimen_ejercicio.estatus', '=', 1);
	})
	.fetch({ columns: ['id_plan_ejercicio','id_cliente','id_frecuencia','id_tiempo','duracion'] })
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

function saveRegimen_ejercicio(req, res, next){
	console.log(JSON.stringify(req.body));

	Regimen_ejercicio.forge({ id_plan_ejercicio:req.body.id_plan_ejercicio ,id_cliente:req.body.id_cliente ,id_frecuencia:req.body.id_frecuencia ,id_tiempo:req.body.id_tiempo ,duracion:req.body.duracion  })
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

function getRegimen_ejercicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Regimen_ejercicio.forge({ id_regimen_ejercicio })
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

function updateRegimen_ejercicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Regimen_ejercicio.forge({ id_regimen_ejercicio })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_plan_ejercicio:req.body.id_plan_ejercicio || data.get('id_plan_ejercicio'),id_cliente:req.body.id_cliente || data.get('id_cliente'),id_frecuencia:req.body.id_frecuencia || data.get('id_frecuencia'),id_tiempo:req.body.id_tiempo || data.get('id_tiempo'),duracion:req.body.duracion || data.get('duracion') })
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

function deleteRegimen_ejercicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Regimen_ejercicio.forge({ id_regimen_ejercicio })
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
	getRegimen_ejercicios,
	saveRegimen_ejercicio,
	getRegimen_ejercicioById,
	updateRegimen_ejercicio,
	deleteRegimen_ejercicio
}
