'use strict';

const Servicios = require('../collections/servicios');
const Servicio  = require('../models/servicio');

function getServicios(req, res, next) {
	Servicios.query(function (q) {
        q
         .innerJoin('plan_dieta', function () {
                this.on('servicio.id_plan_dieta', '=', 'plan_dieta.id_plan_dieta');
            })
         .innerJoin('plan_ejercicio', function () {
                this.on('servicio.id_plan_ejercicio', '=', 'plan_ejercicio.id_plan_ejercicio');
            })
         .innerJoin('plan_suplemento', function () {
                this.on('servicio.id_plan_suplemento', '=', 'plan_suplemento.id_plan_suplemento');
            });
	})
	.fetch({ withRelated: ['plan_dieta', 'plan_dieta.tipo_dieta','plan_ejercicio', 'plan_suplemento'] })
	.then(function(servicios) {
		//console.log(servicios.at(0).related('plan_dieta'));
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

function getServicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Servicio.forge({ id_servicio: id, estatus: 1 })
	.fetch()
	.then(function(servicio) {
		if(!servicio) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Servicio no encontrado' } 
			});
		return res.status(200).json({ 
			error : false, 
			data : servicio 
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function saveServicio(req, res, next){
	console.log(JSON.stringify(req.body));

	Servicio.forge({
		id_plan_dieta: req.body.id_plan_dieta,
		id_plan_ejercicio: req.body.id_plan_ejercicio, 
		id_plan_suplemento: req.body.id_plan_suplemento, 
        nombre: req.body.nombre, 
        descripcion: req.body.descripcion, 
        url_imagen: req.body.url_imagen, 
        precio: req.body.precio, 
        numero_visita: req.body.numero_visita
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

module.exports = {
	getServicios,
	getServicioById,
	saveServicio
}