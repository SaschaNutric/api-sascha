'use strict';

const PlanDietas = require('../collections/plan_dietas');
const PlanDieta  = require('../models/plan_dieta');
const Bluebird   = require('bluebird');

function getPlanDietas(req, res, next) {
	PlanDietas.query(function (q) {
        q.innerJoin('tipo_dieta', function () {
			this.on('plan_dieta.id_tipo_dieta', '=', 'tipo_dieta.id_tipo_dieta');
		});
		q.where('estatus', '=', 1);
	})
	.fetch({ withRelated: ['tipo_dieta', 'detalle.comida', 'detalle.grupoAlimenticio'] })
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Registros no encontrado' } 
			});

		let planesDieta = [];
		data.toJSON().map(function(plan) {
			let comidasAsignadas = [];
			plan.detalle.map(function (comida) {
				let index = comidasAsignadas.map(function (comidaAsignada) {
												return comidaAsignada.id_comida;
											})
											.indexOf(comida.id_comida);
				if (index == -1) {
					comidasAsignadas.push({
						id_comida: comida.comida.id_comida,
						nombre:    comida.comida.nombre,
						grupos_alimenticios: [{ 
								id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
								nombre:               comida.grupoAlimenticio.nombre
							}]
					})
				}
				else {
					comidasAsignadas[index].grupos_alimenticios.push({
						id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
						nombre:               comida.grupoAlimenticio.nombre
					})
				}
			})
			planesDieta.push({
				id_plan_dieta: plan.id_plan_dieta,
				nombre:        plan.nombre,
				descripcion:   plan.descripcion,
				tipo_dieta: { 
					id_tipo_dieta: plan.tipo_dieta.id_tipo_dieta,
					nombre:        plan.tipo_dieta.nombre
				},
				comidas: comidasAsignadas
			})	
		});
		return res.status(200).json({
			error: false,
			data: planesDieta
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function savePlanDieta(req, res, next){
	PlanDieta.forge({
		id_tipo_dieta: req.body.id_tipo_dieta,
        nombre: req.body.nombre, 
        descripcion: req.body.descripcion
	})
	.save()
	.tap(function(plan) {
		Bluebird.map(req.body.detalle, function(comida) {
			plan.related('detalle').create(comida);
		})
	})
	.then(function(data){
		let planDieta = data.toJSON();
		let comidasAsignadas = [];
		console.log(req.body.detalle)
		req.body.detalle.map(function(comida) {
			let index = comidasAsignadas.map(function (comidaAsignada) { 
												return comidaAsignada.id_comida; 
										})
										.indexOf(comida.id_comida);
			if(index == -1) {
				comidasAsignadas.push({ 
					id_comida: comida.id_comida, 
					grupos_alimenticios: [{ id_grupo_alimenticio: comida.id_grupo_alimenticio }] 
				})
			}
			else {
				comidasAsignadas[index].grupos_alimenticios.push({ 
					id_grupo_alimenticio: comida.id_grupo_alimenticio 
				})
			}
		})
		planDieta['comidas'] = comidasAsignadas;
		res.status(200).json({
			error: false,
			data: planDieta
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

function getPlanDietaById(req, res, next) {
		const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

		PlanDieta.query(function (q) {
        	q.innerJoin('tipo_dieta', function () {
                this.on('plan_dieta.id_tipo_dieta', '=', 'tipo_dieta.id_tipo_dieta')
                	.andOn('plan_dieta.id_plan_dieta', '=', id)
             		.andOn('plan_dieta.estatus', '=', 1);
            });
	})
	.fetch({ withRelated: ['tipo_dieta', 'detalle.comida', 'detalle.grupoAlimenticio'] })
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Plan de dieta no encontrada' } 
			});

		let plan = data.toJSON();
		let comidasAsignadas = [];
		plan.detalle.map(function (comida) {
			let index = comidasAsignadas.map(function (comidaAsignada) {
											return comidaAsignada.id_comida;
										})
										.indexOf(comida.id_comida);
			if (index == -1) {
				comidasAsignadas.push({
					id_comida: comida.comida.id_comida,
					nombre: comida.comida.nombre,
					grupos_alimenticios: [{
						id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
						nombre: comida.grupoAlimenticio.nombre
					}]
				})
			}
			else {
				comidasAsignadas[index].grupos_alimenticios.push({
					id_grupo_alimenticio: comida.grupoAlimenticio.id_grupo_alimenticio,
					nombre: comida.grupoAlimenticio.nombre
				})
			}
		})
		
		let planDieta = {
			id_plan_dieta: plan.id_plan_dieta,
			nombre: plan.nombre,
			descripcion: plan.descripcion,
			tipo_dieta: {
				id_tipo_dieta: plan.tipo_dieta.id_tipo_dieta,
				nombre: plan.tipo_dieta.nombre
			},
			comidas: comidasAsignadas
		}
		
		return res.status(200).json({ 
			error: false, 
			data:  planDieta 
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function updatePlanDieta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	PlanDieta.forge({ id_plan_dieta: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
			id_tipo_dieta: req.body.id_tipo_dieta || data.get('id_tipo_dieta'),
        	nombre: req.body.nombre || data.get('nombre'), 
        	descripcion: req.body.descripcion || data.get('descripcion')
		})
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

function deletePlanDieta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	PlanDieta.forge({ id_plan_dieta: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Plan de dieta no encontrado' } 
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
				data: { mensaje: err.message } 
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
	getPlanDietas,
	savePlanDieta,
	getPlanDietaById,
	updatePlanDieta,
	deletePlanDieta
}