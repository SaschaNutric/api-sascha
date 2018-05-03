'use strict';

const PlanDietas = require('../collections/plan_dietas');
const PlanDieta  = require('../models/plan_dieta');

function getPlanDietas(req, res, next) {
	PlanDietas.query(function (q) {
        q
         .innerJoin('tipo_dieta', function () {
                this.on('plan_dieta.id_tipo_dieta', '=', 'tipo_dieta.id_tipo_dieta');
            });
	})
	.fetch({ withRelated: ['tipo_dieta'] })
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Registros no encontrado' } 
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

function savePlanDieta(req, res, next){
	PlanDieta.forge({
		id_tipo_dieta: req.body.id_tipo_dieta,
        nombre: req.body.nombre, 
        descripcion: req.body.descripcion
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

function getPlanDietaById(req, res, next) {
		const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

//.forge({ id_unidad: id, estatus: 1 })
	PlanDieta.query(function (q) {
        	q
         	.innerJoin('tipo_dieta', function () {
                this.on('plan_dieta.id_tipo_dieta', '=', 'tipo_dieta.id_tipo_dieta')
                	.andOn('plan_dieta.id_plan_dieta', '=', id)
             		.andOn('plan_dieta.estatus', '=', 1);
            });
	})
	.fetch({ withRelated: ['tipo_dieta'] })
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
	getPlanDietas,
	savePlanDieta,
	getPlanDietaById,
	updatePlanDieta,
	deletePlanDieta
}