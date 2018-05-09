'use strict';

const Comentarios 	= require('../collections/comentarios');
const Comentario  	= require('../models/comentario');

function getComentarios(req, res, next) {
	Comentarios.query(function (qb) {
   		qb.where('comentario.estatus', '=', 1);
	})
	.fetch({ withRelated: [
		'id_comentario',
		'id_cliente',
		'respuesta',
		'respuesta.tipo_respuesta',
		'motivo',
		'motivo.tipo_motivo'
		]})
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
			data: data
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
		respuesta: req.body.respuesta  
	})
	.save()
	.then(function(data){
		res.status(200).json({
			error: false,
			data: [{
				msg: "Registro Creado"
			}]
		});
	})
	.catch(function (err) {
		res.status(500)
		.json({
			error: true,
			data: data
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
		'id_comentario',
		'id_cliente',
		'respuesta',
		'respuesta.tipo_respuesta',
		'motivo',
		'motivo.tipo_motivo'
		]})
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: data
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
				data: data 
			});
		data.save({ 
			id_cliente: req.body.id_cliente 	|| data.get('id_cliente'),
			id_respuesta: req.body.id_respuesta || data.get('id_respuesta') || null,
			id_motivo: req.body.id_motivo 		|| data.get('id_motivo'), 
			contenido: req.body.contenido 		|| data.get('contenido'),
			respuesta: req.body.respuesta  		|| data.get('respuesta')
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
	getComentarios,
	saveComentario,
	getComentarioById,
	updateComentario,
	deleteComentario
}
