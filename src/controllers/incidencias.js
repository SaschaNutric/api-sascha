'use strict';

const Incidencias 	= require('../collections/incidencias');
const Incidencia  	= require('../models/incidencia');
const Bookshelf = require('../commons/bookshelf');
const Cita = require('../models/cita');

function getIncidencias(req, res, next) {
	Incidencias.query(function (qb) {
   		qb.where('incidencia.estatus', '=', 1);
	})
	.fetch({ 
		withRelated: [
			'tipoIncidencia', 
			'motivo'
		],
		columns: [
			'id_incidencia',
			'tipoIncidencia',
			'motivo',
			'descripcion',
			'id_agenda'
		] 
	})
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

function saveIncidencia(req, res, next){
	if (!req.body.id_tipo_incidencia || !req.body.id_motivo
		|| !req.body.descripcion     || !req.body.id_cita
		|| !req.body.id_agenda)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		})

	Bookshelf.transaction(function(t) {
		Incidencia.forge({ 
			id_tipo_incidencia: req.body.id_tipo_incidencia,
			id_motivo: req.body.id_motivo,
			descripcion: req.body.descripcion,
			id_agenda: req.body.id_agenda
		})
		.save(null, { transacting: t })
		.then(function(data) {
			Cita.forge({ id_cita: req.body.id_cita })
			.fetch()
			.then(function(cita) {
				cita.save({ id_tipo_cita: 3 })
				.then(function(citaActualizada) {
					t.commit();
					res.status(200).json({
						error: false,
						data: data
					});
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
				t.rollback();
				res.status(500).json({
					error: true,
					data: { message: err.message }
				});
			});
		})
		.catch(function (err) {
			t.rollback();
			res.status(500).json({
				error: true,
				data: {message: err.message}
			});
		});
	});
}

function getIncidenciaById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Incidencia.forge({ id_incidencia: id })
	.fetch({
		withRelated: [
			'tipoIncidencia',
			'motivo'
		]
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

function updateIncidencia(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Incidencia.forge({ id_incidencia: id })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_tipo_incidencia:req.body.id_tipo_incidencia || data.get('id_tipo_incidencia'),id_motivo:req.body.id_motivo || data.get('id_motivo'),descripcion:req.body.descripcion || data.get('descripcion'),id_agenda:req.body.id_agenda || data.get('id_agenda') })
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

function deleteIncidencia(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Incidencia.forge({ id_incidencia: id })
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
	getIncidencias,
	saveIncidencia,
	getIncidenciaById,
	updateIncidencia,
	deleteIncidencia
}
