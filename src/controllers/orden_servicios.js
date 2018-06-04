'use strict';

const Orden_servicios 	= require('../collections/orden_servicios');
const Orden_servicio_reporte     = require ('../collections/vista_reporte_orden_servicio');
const Orden_servicio  	= require('../models/orden_servicio');

function getOrden_servicios(req, res, next) {
	Orden_servicios.query(function (qb) {
   		qb.where('orden_servicio.estatus', '=', 1);
	})
	.fetch({ columns: ['id_orden_servicio','id_solicitud_servicio','id_tipo_orden','id_meta','fecha_emision','fecha_caducidad','id_reclamo'] })
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

function saveOrden_servicio(req, res, next){
	console.log(JSON.stringify(req.body));

	Orden_servicio.forge({ id_solicitud_servicio:req.body.id_solicitud_servicio ,id_tipo_orden:req.body.id_tipo_orden ,id_meta:req.body.id_meta ,fecha_emision:req.body.fecha_emision ,fecha_caducidad:req.body.fecha_caducidad ,id_reclamo:req.body.id_reclamo  })
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

function getOrden_servicioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Orden_servicio.forge({ id_orden_servicio: id, estatus: 1 })
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

function reportOrdenServicio(req, res, next) {
	let campos = {
		// id_motivo:           req.body.id_motivo           || null,
		id_tipo_orden:       req.body.id_tipo_orden       || null,
		estado:              req.body.estado              || null,
		id_especialidad:     req.body.id_especialidad     || null,
		id_servicio:         req.body.id_servicio         || null,
		id_genero:           req.body.id_genero           || null,
		id_estado_civil:     req.body.id_estado_civil     || null,
		id_rango_edad:       req.body.id_rango_edad       || null
	}


	 let rango_fecha = {
	 	minimo: req.body.fecha_inicial || null,
     	maximo: req.body.fecha_final || null
	 }

		let filtros = new Object();
	for(let item in campos) {
		if(campos.hasOwnProperty(item)) {
			if(campos[item] != null) 
				filtros[item] = campos[item];
		}
	}

		Orden_servicio_reporte.query(function(qb) {
		   qb.where(filtros);
		   	if (rango_fecha.minimo && rango_fecha.maximo)
			 qb.where('fecha_emision', '>=', rango_fecha.minimo)
			  .andWhere('fecha_emision', '<=', rango_fecha.maximo);
		})
		.fetch()
		.then(function(ordenes) {
			let nuevasOrdenes = new Array();

			res.status(200).json({ error: false, data: ordenes });
		})
		.catch(function(err) {
			return res.status(500).json({ error: true, data: { mensaje: err.message } });
		});


}

function updateOrden_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Orden_servicio.forge({ id_orden_servicio: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ 
			id_solicitud_servicio: 	req.body.id_solicitud_servicio  || data.get('id_solicitud_servicio'),
			id_tipo_orden: 			req.body.id_tipo_orden 			|| data.get('id_tipo_orden'),
			id_meta: 				req.body.id_meta 				|| data.get('id_meta'),
			fecha_emision: 			req.body.fecha_emision 			|| data.get('fecha_emision'),
			fecha_caducidad: 		req.body.fecha_caducidad 		|| data.get('fecha_caducidad'),
			id_reclamo: 			req.body.id_reclamo 			|| data.get('id_reclamo') ,
			estado: 				req.body.estado 				|| data.get('estado')
		})
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

function deleteOrden_servicio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Orden_servicio.forge({ id_orden_servicio: id, estatus: 1 })
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
	getOrden_servicios,
	saveOrden_servicio,
	getOrden_servicioById,
	reportOrdenServicio,
	updateOrden_servicio,
	deleteOrden_servicio
}
