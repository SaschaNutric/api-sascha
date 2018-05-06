'use strict';

const Valoraciones 	= require('../collections/valoraciones');
const Valoracion  	= require('../models/valoracion');

function getValoraciones(req, res, next) {
	Valoraciones.query(function (q) {
        q.innerJoin('tipo_valoracion', function () {
                this.on('valoracion.id_tipo_valoracion', '=', 'tipo_valoracion.id_tipo_valoracion');
            });
		q.where('valoracion.estatus', '=', 1);
	})
	.fetch({ withRelated: ['tipo_valoracion'] })
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

function saveValoracion(req, res, next){
	console.log(JSON.stringify(req.body));

	Valoracion.forge({ id_tipo_valoracion:req.body.id_tipo_valoracion ,nombre:req.body.nombre  })
	.save()
	.then(function(data){
		Valoracion.query(function (q) {
			q.where('valoracion.id_valoracion', '=', data.get('id_valoracion'));
	        q.innerJoin('tipo_valoracion', function () {
                this.on('valoracion.id_tipo_valoracion', '=', data.get('id_tipo_valoracion'));
            });
			q.where('valoracion.estatus', '=', 1);
		})
		.fetch({ withRelated: ['tipo_valoracion'] })
		.then(function(valoracion) {
			res.status(200).json({
				error: false,
				data: valoracion
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

function getValoracionById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Valoracion.query(function (q) {
        	q
         	.innerJoin('tipo_valoracion', function () {
                this.on('valoracion.id_tipo_valoracion', '=', 'tipo_valoracion.id_tipo_valoracion')
                	.andOn('id_valoracion', '=', id)
             		.andOn('valoracion.estatus', '=', 1);
            });
	})
	.fetch({ withRelated: ['tipo_valoracion'] })
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

function updateValoracion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Valoracion.forge({ id_valoracion: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_tipo_valoracion:req.body.id_tipo_valoracion || data.get('id_tipo_valoracion'),nombre:req.body.nombre || data.get('nombre') })
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

function deleteValoracion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Valoracion.forge({ id_valoracion: id, estatus: 1 })
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
	getValoraciones,
	saveValoracion,
	getValoracionById,
	updateValoracion,
	deleteValoracion
}
