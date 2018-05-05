'use strict';

const Unidades = require('../collections/unidades');
const Unidad  = require('../models/unidad');

function getUnidades(req, res, next) {
	Unidades.query(function (q) {
        q.innerJoin('tipo_unidad', function () {
                this.on('unidad.id_tipo_unidad', '=', 'tipo_unidad.id_tipo_unidad');
            });
		q.where('unidad.estatus', '=', 1);
	})
	.fetch({ withRelated: ['tipo_unidad'] })
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

function saveUnidad(req, res, next){
	Unidad.forge({
 		id_tipo_unidad: req.body.id_tipo_unidad, 
        nombre: req.body.nombre,
        abreviatura: req.body.abreviatura,
        simbolo: req.body.simbolo,
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

function saveUnidad2(req, res, next){
	Unidad.forge({
 		id_tipo_unidad: req.body.id_tipo_unidad, 
        nombre: req.body.nombre,
        abreviatura: req.body.abreviatura,
        simbolo: req.body.simbolo,
	})
	.save()
	.then(function(data){
		Unidad.query(function (q) {
			q.where('unidad.id_unidad', '=', data.get('id_unidad'));
	        q.innerJoin('tipo_unidad', function () {
                this.on('unidad.id_tipo_unidad', '=', data.get('id_tipo_unidad'));
            });
			q.where('unidad.estatus', '=', 1);
		})
		.fetch({ withRelated: ['tipo_unidad'] })
		.then(function(unidad) {
			res.status(200).json({
				error: false,
				data: unidad
			});
		})
	})
	.catch(function (err) {
		res.status(500)
		.json({
			error: true,
			data: {message: err.message}
		});
	});
}
function getUnidadById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Unidad.query(function (q) {
        	q
         	.innerJoin('tipo_unidad', function () {
                this.on('unidad.id_tipo_unidad', '=', 'tipo_unidad.id_tipo_unidad')
                	.andOn('id_unidad', '=', id)
             		.andOn('unidad.estatus', '=', 1);
            });
	})
	.fetch({ withRelated: ['tipo_unidad'] })
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

function updateUnidad(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Unidad.forge({ id_unidad: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
			id_tipo_unidad: req.body.id_tipo_unidad || data.get('id_tipo_unidad'), 
			nombre: req.body.nombre 				|| data.get('nombre'),
        	abreviatura: req.body.abreviatura 		|| data.get('abreviatura'),
        	simbolo: req.body.simbolo		 		|| data.get('simbolo')
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

function deleteUnidad(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Unidad.forge({ id_unidad: id, estatus: 1 })
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
	getUnidades,
	saveUnidad,
	getUnidadById,
	updateUnidad,
	deleteUnidad
}
