'use strict';

const PlanSuplementos = require('../collections/plan_suplementos');
const PlanSuplemento  = require('../models/plan_suplemento');
const Bluebird        = require('bluebird');

function getPlanSuplementos(req, res, next) {
	PlanSuplementos.query(function (qb) {
   		qb.where('plan_suplemento.estatus', '=', 1);
	})
	.fetch({ withRelated: [
		'suplementos',
		'suplementos.unidad'
		] })
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay servicios registrados' } 
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

function savePlanSuplemento(req, res, next){
	PlanSuplemento.forge({
        nombre: req.body.nombre,
        descripcion: req.body.descripcion
	})
	.save()
	.tap(function(plan) {
		let suplementosAsignados = [];
		Bluebird.map(req.body.suplementos, function(suplemento) {
			plan.related('suplementos').create(suplemento)
			suplementosAsignados.push(suplemento)
		})
		.then(function() {
			plan.suplementos = suplementosAsignados;
		});
	})
	.then(function(plan) {
		let planSuplemento = plan.toJSON()
		planSuplemento['suplementos'] = req.body.suplementos;	
		res.status(200).json({
			error: false,
			data: planSuplemento
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

function getPlanSuplementoById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	PlanSuplemento.forge({ id_plan_suplemento: id, estatus: 1 })
	.fetch({ withRelated: [
		'suplementos',
		'suplementos.unidad'
		] })
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Servicio no encontrado' } 
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

function updatePlanSuplemento(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	PlanSuplemento.forge({ id_plan_suplemento: id, estatus: 1 })
	.fetch({ withRelated: [
		'suplementos',
		'suplementos.unidad'
		] })
	.then(function(data1){
		if(!data1) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
			nombre: req.body.nombre || data1.get('nombre'),
			descripcion: req.body.descripcion || data1.get('descripcion')
		})
		.then(function(data) {
			return res.status(200).json({ 
				error: false, 
				data: {
					id_plan_suplemento: data.get('id_plan_suplemento'),
					nombre: data.get('nombre'),
					descripcion: data.get('descripcion'),
					suplemento: data1.get('suplemento')
				}
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

function deletePlanSuplemento(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	PlanSuplemento.forge({ id_plan_suplemento: id, estatus: 1 })
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
	getPlanSuplementos,
	savePlanSuplemento,
	getPlanSuplementoById,
	updatePlanSuplemento,
	deletePlanSuplemento
}