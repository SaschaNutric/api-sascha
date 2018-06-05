'use strict';

const Comentarios 	= require('../collections/comentarios');
const Comentario  	= require('../models/comentario');
const vista_canal_escuchas = require ('../collections/vista_canal_escuchas');

function getVistaComentario(filtros, rango_fecha) {
		let where = '';
	for (let filtro in filtros) {
		if (filtro == 'id_tipo_motivo')  where += ' AND mo.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_motivo')       where += ' AND co.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_respuesta')    where += ' AND res.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_genero')       where += ' AND cli.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_estado_civil') where += ' AND cli.' + filtro + '=' + filtros[filtro];
		if (filtro == 'id_rango_edad')   where += ' AND cli.' + filtro + '=' + filtros[filtro];
	}
	if (rango_fecha.minimo && rango_fecha.maximo) {
		where += " AND fecha_emision >= '" + rango_fecha.minimo + "' AND fecha_emision <= '" + rango_fecha.maximo + "' ";
	}
return "SELECT co.id_comentario, " +
"co.id_cliente, " +
"(cli.nombres:: text || ' ':: text) || cli.apellidos:: text AS nombre_cliente, " +
"mo.id_tipo_motivo, " +
"tm.nombre AS tipo_motivo, " +
"co.id_motivo, " +
"mo.descripcion AS motivo_descripcion, " +
"res.id_respuesta, " +
"res.descripcion AS respuesta, " +
"co.mensaje AS respuesta_personalizada, " +
"co.fecha_creacion, " +
"cli.id_genero, " +
"cli.id_rango_edad, " +
"cli.id_estado_civil, " +
"ARRAY(SELECT pc.id_parametro " +
"FROM parametro_cliente pc " +
"WHERE pc.id_cliente = cli.id_cliente) AS perfil_cliente " +
"FROM comentario co, " +
"cliente cli, " +
"motivo mo, " +
"tipo_motivo tm, " +
"respuesta res " +
"WHERE co.id_cliente = cli.id_cliente AND co.id_motivo = mo.id_motivo  " +
"AND mo.id_tipo_motivo = tm.id_tipo_motivo AND co.id_respuesta = res.id_respuesta " +
"ORDER BY co.fecha_creacion DESC";
}

function getComentarios(req, res, next) {
	Comentarios.query(function (qb) {
		   qb.where('comentario.estatus', '=', 1);
		   qb.orderBy('comentario.fecha_creacion','desc');
	})
	.fetch({ withRelated: [
		'cliente',
		'cliente.estado_civil',
		'cliente.genero',
		'cliente.rango_edad',
		'respuesta',
		'respuesta.tipo_respuesta',
		'motivo',
		'motivo.tipo_motivo'
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

function saveComentario(req, res, next){
	console.log(JSON.stringify(req.body));

	Comentario.forge({ 
		id_cliente: req.body.id_cliente,
		id_respuesta: req.body.id_respuesta || null,
		id_motivo: req.body.id_motivo, 
		contenido: req.body.contenido ,
		mensaje: req.body.mensaje || null
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
			data: { mensaje: err.message }
		});
	});
}

function getComentarioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Comentario.forge({ id_comentario: id, estatus: 1 })
	.fetch({ withRelated: [
		'cliente',
		'cliente.estado_civil',
		'cliente.genero',
		'cliente.rango_edad',
		'respuesta',
		'respuesta.tipo_respuesta',
		'motivo',
		'motivo.tipo_motivo'
	] })
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: 'Comentario no encontrado'
			});
		return res.status(200).json({ 
			error: false, 
			data: data 
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function updateComentario(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Comentario.forge({ id_comentario: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		console.log(req.body);
		let body = { 
			id_cliente: req.body.id_cliente 	|| data.get('id_cliente'),
			id_respuesta: req.body.id_respuesta || data.get('id_respuesta') || null,
			id_motivo: req.body.id_motivo 		|| data.get('id_motivo'), 
			contenido: req.body.contenido 		|| data.get('contenido'),
			mensaje: req.body.mensaje  			|| data.get('mensaje')
		}; 
		console.log(body);
		data.save(body)
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


function deleteComentario(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Comentario.forge({ id_comentario: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Comentario no encontrado' } 
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

function reporteComentario(req, res, next) {
	let campos = {
		id_tipo_motivo:		 req.body.id_tipo_motivo		  || null,
		id_motivo:           req.body.id_motivo           || null,
		id_respuesta:        req.body.id_respuesta        || null,
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
		vista_canal_escuchas.query(function(qb) {
		   qb.where(filtros);
		   	if (rango_fecha.minimo && rango_fecha.maximo)
				qb.where('fecha_creacion', '>=', rango_fecha.minimo)
				  .andWhere('fecha_creacion', '<=', rango_fecha.maximo);
			queryString = qb.toString();
		})
		.fetch()
		.then(function(comentarios) {
			let nuevosComentarios = new Array();

			res.status(200).json({ error: false, data: comentarios, query: getVistaComentario(filtros, rango_fecha) });
		})
		.catch(function(err) {
			return res.status(500).json({ error: true, data: { mensaje: err.message } });
		});
}

module.exports = {
	getComentarios,
	saveComentario,
	getComentarioById,
	updateComentario,
	deleteComentario,
	reporteComentario
}
