'use strict';

const Reclamos 	= require('../collections/reclamos');
const Reclamo  	= require('../models/reclamo');
const OrdenServicio   = require('../models/orden_servicio');
const Bookshelf = require('../commons/bookshelf');
const vista_reclamos = require ('../collections/vista_reclamos');

function getVistaReclamo(filtros, rango_fecha) {
	let where = '';
	for (let filtro in filtros) {
		if (filtro == 'id_motivo')       where += ' AND mo.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_respuesta')    where += ' AND res.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_especialidad') where += ' AND serv.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_servicio')     where += ' AND serv.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_genero')       where += ' AND cli.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_estado_civil') where += ' AND cli.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_rango_edad')   where += ' AND cli.' + filtro + '=' + filtros[filtro];		
	}
	if (rango_fecha.minimo && rango_fecha.maximo) {
		where += " AND r.fecha_creacion >= '" + rango_fecha.minimo + "' AND r.fecha_creacion <= '" + rango_fecha.maximo + "' ";
	}
return "SELECT DISTINCT r.id_reclamo, " +
"res.aprobado, " +
"cli.id_usuario, " +
"(cli.nombres:: text || ' ':: text) || cli.apellidos:: text AS nombre_cliente, " +
"e.id_empleado, " +
"(e.nombres:: text || ' ':: text) || e.apellidos:: text AS nombre_empleado, " +
"s.id_servicio, " +
"serv.nombre AS nombre_servicio, " +
"serv.id_especialidad, " +
"mo.descripcion AS motivo_descripcion, " +
"mo.id_motivo, " +
"r.id_respuesta, " +
"res.descripcion AS respuesta_descripcion, " +
"r.fecha_creacion, " +
"cli.id_genero, " +
"cli.id_estado_civil, " +
"cli.id_rango_edad " +
"FROM reclamo r, " +
"orden_servicio o, " +
"solicitud_servicio s, " +
"agenda ag, " +
"empleado e, " +
"cliente cli, " +
"servicio serv, " +
"motivo mo, " +
"respuesta res " +
"WHERE r.id_orden_servicio = o.id_orden_servicio AND o.id_solicitud_servicio = s.id_solicitud_servicio  " +
"AND s.id_cliente = cli.id_cliente AND s.id_servicio = serv.id_servicio AND r.id_respuesta = res.id_respuesta  " +
"AND r.id_motivo = mo.id_motivo AND ag.id_orden_servicio = o.id_orden_servicio  " +
"AND ag.id_empleado = e.id_empleado AND r.id_respuesta IS NOT NULL " +
where +
"ORDER BY r.fecha_creacion DESC";
}

function getReclamos(req, res, next) {
	Reclamos.query(function (qb) {
		   qb.where('reclamo.estatus', '=', 1);
		   qb.whereNull('reclamo.id_respuesta');
	})
	.fetch({
		withRelated: [
		'motivo', 
		'respuesta', 
		'ordenServicio',
		'ordenServicio.solicitud',
		'ordenServicio.solicitud.cliente',
		'ordenServicio.solicitud.servicio',
		'ordenServicio.solicitud.servicio.condiciones_garantia'
		]
	})
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay dato registrados' } 
			});
		let arrayReclamos = data.toJSON();
		let reclamos = [];

		arrayReclamos.map(function(reclamo) {
			if (JSON.stringify(reclamo.ordenServicio)!= '{}') {
				reclamos.push({
					id_reclamo: reclamo.id_reclamo,
					id_motivo: reclamo.id_motivo,
					id_respuesta: reclamo.id_respuesta,
					id_orden_servicio: reclamo.id_orden_servicio,
					respuesta: reclamo.respuesta,
					motivo: reclamo.motivo.descripcion,
					fecha: reclamo.fecha_creacion,
					id_servicio: reclamo.ordenServicio.solicitud.servicio.id_servicio,
					servicio: reclamo.ordenServicio.solicitud.servicio.nombre,
					condiciones_garantia : reclamo.ordenServicio.solicitud.servicio.condiciones_garantia,
					id_cliente: reclamo.ordenServicio.solicitud.cliente.id_cliente,
					cliente: reclamo.ordenServicio.solicitud.cliente.nombres,
				});	
			}
			
		});

		return res.status(200).json({
			error: false,
			data: reclamos
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function saveReclamo(req, res, next){
	console.log(JSON.stringify(req.body));
	if (!req.body.id_motivo || !req.body.id_orden_servicio) {
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		})
	}
	OrdenServicio.forge({ id_orden_servicio: req.body.id_orden_servicio })
	.fetch()
	.then(function (orden) {
		let reclamo = orden.get('id_reclamo');
		if(reclamo) {
			return res.status(403).json({
				error: true,
				data: { mensaje: 'Orden de servicio ya ha sido reclamada' }
			})			
		}
		else {
			Bookshelf.transaction(function (t) {
				Reclamo.forge({
					id_motivo: req.body.id_motivo,
					id_orden_servicio: req.body.id_orden_servicio,
					id_respuesta: req.body.id_respuesta || null,
					respuesta: req.body.respuesta || null
				})
				.save(null, { transacting: t })
				.then(function (data) {
					orden.save({ estado: 2, id_reclamo: data.get('id_reclamo') }, { transacting: t })
					.then(function (orden) {
						t.commit()
						res.status(200).json({
							error: false,
							data: { mensaje: 'Reclamo del servicio realizado satisfactoriamente' }
						});
					})
					.catch(function (err) {
						t.rollback()
						return res.status(500).json({
							error: false,
							data: { mensaje: err.message }
						})
					})
				})
				.catch(function (err) {
					t.rollback();
					res.status(500).json({
						error: true,
						data: { message: err.message }
					});
				});
			})
			.catch(function (err) {
				return res.status(500).json({
					error: false,
					data: { mensaje: err.message }
				})
			})
		}
	})
	.catch(function (err) {
		res.status(500).json({
			error: true,
			data: { message: err.message }
		});
	});
}

function getReclamoById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Reclamo.forge({ id_reclamo: id, estatus : 1 })
	.fetch({
		withRelated: ['motivo', 'respuesta', 'ordenServicio'],
		columns: ['id_motivo', 'id_orden_servicio', 'id_respuesta', 'respuesta'] 
	})
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

function updateReclamo(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Reclamo.forge({ id_reclamo: id, estatus:1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_motivo:req.body.id_motivo || data.get('id_motivo'),id_orden_servicio:req.body.id_orden_servicio || data.get('id_orden_servicio'),id_respuesta:req.body.id_respuesta || data.get('id_respuesta'),respuesta:req.body.respuesta || data.get('respuesta') })
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

function deleteReclamo(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Reclamo.forge({ id_reclamo })
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

function reporteReclamo(req, res, next) {
	let campos = {
		id_motivo:           req.body.id_motivo           || null,
		id_respuesta:        req.body.id_respuesta        || null,
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
		let queryString = '';
		vista_reclamos.query(function(qb) {
		   qb.where(filtros);
		   	if (rango_fecha.minimo && rango_fecha.maximo)
				qb.where('fecha_creacion', '>=', rango_fecha.minimo)
				  .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
			queryString = qb.toString();
		})
		.fetch()
		.then(function(reclamos) {
			let nuevosReclamos = new Array();

			res.status(200).json({ error: false, data: reclamos, query: getVistaReclamo(filtros, rango_fecha) });
		})
		.catch(function(err) {
			return res.status(500).json({ error: true, data: { mensaje: err.message } });
		});
}

module.exports = {
	getReclamos,
	saveReclamo,
	getReclamoById,
	updateReclamo,
	deleteReclamo,
	reporteReclamo
}
