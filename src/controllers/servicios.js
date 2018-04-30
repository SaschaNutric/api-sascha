'use strict';

const Servicios = require('../collections/servicios');
const Servicio  = require('../models/servicio');

/*
.query(function (q) {
        q.distinct()
         .innerJoin('plan_dieta', function () {
                this.on('servicio.id_plan_dieta', '=', 'plan_dieta.id_plan_dieta');
            })
         .innerJoin('tipo_dieta', function () {
                this.on('tipo_dieta.id_tipo_dieta', '=', 'plan_dieta.id_tipo_dieta');
            })
         .innerJoin('plan_ejercicio', function () {
                this.on('servicio.id_plan_ejercicio', '=', 'plan_ejercicio.id_plan_ejercicio');
            })
         .innerJoin('plan_suplemento', function () {
                this.on('servicio.id_plan_suplemento', '=', 'plan_suplemento.id_plan_suplemento');
            });
	})
*/
/*
'plan_dieta',
		'plan_dieta.tipo_dieta',
		'plan_ejercicio',
		'plan_suplemento',
		'precio',
		'precio.unidad',
		'precio.unidad.tipo_unidad'	
*/
async function getServicios(req, res, next) {
	await Servicios
	.query(function (qb) {
   		//qb.innerJoin('plan_ejercicio', 'servicio.id_plan_ejercicio', 'plan_ejercicio.id_plan_ejercicio');
   		//qb.innerJoin('plan_dieta', 'servicio.id_plan_dieta', 'plan_dieta.id_plan_dieta');
   		//qb.innerJoin('plan_suplemento', 'servicio.id_plan_suplemento', 'plan_suplemento.id_plan_suplemento');
   		//qb.innerJoin('precio', 'servicio.id_precio', 'precio.id_precio');
   		qb.groupBy('servicio.id_servicio');
   		qb.where('servicio.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'plan_dieta',
			'plan_ejercicio',
			'plan_suplemento',
			'precio',
			'precio.unidad',
			'precio.unidad.tipo_unidad'	
		] })
	.then(function(data) {
		//console.log(servicios.at(0).related('plan_dieta'));
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

function getServicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Servicio.forge({ id_servicio: id, estatus: 1 })
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

function saveServicio(req, res, next){
	Servicio.forge({
		id_plan_dieta: req.body.id_plan_dieta,
		id_plan_ejercicio: req.body.id_plan_ejercicio, 
		id_plan_suplemento: req.body.id_plan_suplemento, 
        nombre: req.body.nombre, 
        descripcion: req.body.descripcion, 
        url_imagen: req.body.url_imagen, 
        precio: req.body.precio, 
        numero_visitas: req.body.numero_visitas
	})
	.save()
	.then(function(data){
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

function updateServicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Servicio.forge({ id_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
        	nombre: req.body.nombre || data.get('nombre'), 
        	descripcion: req.body.descripcion || data.get('descripcion'), 
        	url_imagen: req.body.url_imagen || data.get('url_imagen'), 
        	precio: req.body.precio || data.get('precio'), 
        	numero_visita: req.body.numero_visita || data.get('numero_visita')
		})
		.then(function() {
			return res.status(200).json({ 
				error: false, 
				data: { mensaje: 'Registro actualizado' } 
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

function deleteServicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Servicio.forge({ id_servicio: id, estatus: 1 })
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
	getServicios,
	getServicioById,
	saveServicio,
	updateServicio,
	deleteServicio
}