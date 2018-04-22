'use strict';

const Dietas = require('../collections/plan_dietas');
const PlanDieta  = require('../models/plan_dieta');

function getPlanDietas(req, res, next) {
	Dietas.query(function (q) {
        q
         .innerJoin('tipo_dieta', function () {
                this.on('plan_dieta.id_tipo_dieta', '=', 'tipo_dieta.id_tipo_dieta');
            });
	})
	.fetch({ withRelated: ['tipo_dieta'] })
	.then(function(servicios) {
		if (!servicios)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay servicios registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: servicios
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
	console.log(JSON.stringify(req.body));

	PlanDieta.forge({
		id_tipo_dieta: req.body.id_tipo_dieta,
        nombre: req.body.nombre, 
        descripcion: req.body.descripcion
	})
	.save()
	.then(function(servicio){
		res.status(200).json({
			error: false,
			data: [{
				msg: "Servicio Creado"
			}]
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

	PlanDieta.forge({ id_plan_dieta: id, estatus: 1 })
	.fetch()
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

module.exports = {
	getPlanDietas,
	savePlanDieta,
	getPlanDietaById
}