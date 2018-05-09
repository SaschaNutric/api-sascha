'use strict';

const TipoMotivos = require('../collections/tipo_motivos');
const TipoMotivo  = require('../models/tipo_motivo');

function getTipoMotivos(req, res, next) {
	TipoMotivos.query(function (qb) {
   		qb.where('tipo_motivo.estatus', '=', 1);
	})
	.fetch()
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay datos registrados' } 
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

function getTipoMotivosCanalEscucha(req, res, next) {
	TipoMotivos.query(function (qb) {
		qb.where('tipo_motivo.canal_escucha', '=', true);
		qb.where('tipo_motivo.estatus', '=', 1);
	})
	.fetch({ withRelated: ['motivos'] })
	.then(function (data) {
		if (!data)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'No hay datos registrados' }
			});
		let tipoMotivos = [];
		data.toJSON().map(function(tipoMotivo) {
			let motivos = [];
			tipoMotivo.motivos.map(function(motivo) {
				if(motivo.estatus == 1) {
					motivos.push({
						id_motivo: motivo.id_motivo,
						descripcion: motivo.descripcion
					})
				}
			});
			tipoMotivos.push({
				id_tipo_motivo: tipoMotivo.id_tipo_motivo,
				es_canal_escucha: tipoMotivo.canal_escucha,
				nombre: tipoMotivo.nombre.trim(),
				motivos: motivos
			})
		});
		return res.status(200).json({
			error: false,
			data: tipoMotivos
		});
	})
	.catch(function (err) {
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
	});
}

function saveTipoMotivo(req, res, next){
	console.log(JSON.stringify(req.body));

	TipoMotivo.forge({
        nombre: req.body.nombre
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

function getTipoMotivoById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	TipoMotivo.forge({ id_tipo_motivo: id, estatus: 1 })
	.fetch()
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Dato no encontrado' } 
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

function updateTipoMotivo(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	TipoMotivo.forge({ id_tipo_motivo: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({
			nombre: req.body.nombre || data.get('nombre')
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

function deleteTipoMotivo(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	TipoMotivo.forge({ id_tipo_motivo: id, estatus: 1 })
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
	getTipoMotivos,
	saveTipoMotivo,
	getTipoMotivoById,
	updateTipoMotivo,
	deleteTipoMotivo,
	getTipoMotivosCanalEscucha
}