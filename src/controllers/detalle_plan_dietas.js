'use strict';

const Detalle_plan_dietas 	= require('../collections/detalle_plan_dietas');
const Detalle_plan_dieta  	= require('../models/detalle_plan_dieta');

function getDetalle_plan_dietas(req, res, next) {
	Detalle_plan_dietas.query(function (qb) {
   		qb.where('detalle_plan_dieta.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'plan_dieta',
			'plan_dieta.tipo_dieta',
			'comida',
			'grupo_alimenticio',
			'grupo_alimenticio.unidad',
			'grupo_alimenticio.unidad.tipo_unidad'
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

function saveDetalle_plan_dieta(req, res, next){
	console.log(JSON.stringify(req.body));

	Detalle_plan_dieta.forge({ id_plan_dieta:req.body.id_plan_dieta ,id_comida:req.body.id_comida ,id_grupo_alimenticio:req.body.id_grupo_alimenticio  })
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

function getDetalle_plan_dietaById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Detalle_plan_dieta.forge({ id_detalle_plan_dieta: id, estatus: 1 })
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

function updateDetalle_plan_dieta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Detalle_plan_dieta.forge({ id_detalle_plan_dieta: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_plan_dieta:req.body.id_plan_dieta || data.get('id_plan_dieta'),id_comida:req.body.id_comida || data.get('id_comida'),id_grupo_alimenticio:req.body.id_grupo_alimenticio || data.get('id_grupo_alimenticio') })
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

function deleteDetalle_plan_dieta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Detalle_plan_dieta.forge({ id_detalle_plan_dieta: id, estatus: 1 })
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
	getDetalle_plan_dietas,
	saveDetalle_plan_dieta,
	getDetalle_plan_dietaById,
	updateDetalle_plan_dieta,
	deleteDetalle_plan_dieta
}
