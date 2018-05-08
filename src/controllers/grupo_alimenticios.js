'use strict';

const Grupo_alimenticios 	= require('../collections/grupo_alimenticios');
const Grupo_alimenticio  	= require('../models/grupo_alimenticio');

function getGrupo_alimenticios(req, res, next) {
	Grupo_alimenticios.query(function (qb) {
   		qb.where('grupo_alimenticio.estatus', '=', 1);
	})
	.fetch({ withRelated: ['unidad','unidad.tipo_unidad'] })
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

function saveGrupo_alimenticio(req, res, next){
	console.log(JSON.stringify(req.body));

	Grupo_alimenticio.forge({ id_unidad:req.body.id_unidad ,nombre:req.body.nombre })
	.save()
	.fetch({ withRelated: ['unidad','unidad.tipo_unidad'] })
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

function getGrupo_alimenticioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Grupo_alimenticio.forge({ id_grupo_alimenticio: id, estatus: 1  })
	.fetch({ withRelated: ['unidad','unidad.tipo_unidad'] })
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

function updateGrupo_alimenticio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Grupo_alimenticio.forge({ id_grupo_alimenticio: id, estatus: 1  })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_unidad:req.body.id_unidad || data.get('id_unidad'),nombre:req.body.nombre || data.get('nombre'),fecha_creacion:req.body.fecha_creacion || data.get('fecha_creacion'),fecha_actualizacion:req.body.fecha_actualizacion || data.get('fecha_actualizacion'),estatus:req.body.estatus || data.get('estatus') })
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

function deleteGrupo_alimenticio(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Grupo_alimenticio.forge({ id_grupo_alimenticio: id, estatus: 1  })
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
	getGrupo_alimenticios,
	saveGrupo_alimenticio,
	getGrupo_alimenticioById,
	updateGrupo_alimenticio,
	deleteGrupo_alimenticio
}
