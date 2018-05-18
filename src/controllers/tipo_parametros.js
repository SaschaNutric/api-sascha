'use strict';

const TipoParametros = require('../collections/tipo_parametros');
const TipoParametro  = require('../models/tipo_parametro');

function getTipoParametros(req, res, next) {
	TipoParametros.query(function (qb) {
   		qb.where('tipo_parametro.estatus', '=', 1);
	})
	.fetch({ withRelated: ['parametros','parametros.unidad'] })
	.then(function(data) {
		if (!data)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay datos registrados' } 
			});
	let tipo_parametros = [];
		
		data.toJSON().map(function(tipoParametro) {
			let parametros = [];
			tipoParametro.parametros.map(function(parametro) {
				if(parametro.estatus == 1 ) {
				parametros.push({
					id_parametro:   parametro.id_parametro,
					nombre:      parametro.nombre,
					unidad: parametro.unidad,
					tipo_valor:     parametro.tipo_valor
				});
				}
			});

			tipo_parametros.push({
				id_tipo_parametro: tipoParametro.id_tipo_parametro,
				nombre:         tipoParametro.nombre,
				filtrable: tipoParametro.filtrable,
				parametros:       parametros
			})
		});
		return res.status(200).json({
			error: false,
			data: tipo_parametros
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function saveTipoParametro(req, res, next){
	console.log(JSON.stringify(req.body));

	TipoParametro.forge({
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

function getTipoParametroById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	TipoParametro.forge({ id_tipo_parametro: id, estatus: 1 })
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

function updateTipoParametro(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	TipoParametro.forge({ id_tipo_parametro: id, estatus: 1 })
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


function updateTipoParametroFiltrable(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	}

	TipoParametro.forge({ id_tipo_parametro: id, estatus: 1 })
		.fetch()
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'Tipo parametro no encontrado' }
				});
			data.save({
				filtrable: req.body.filtrable
			})
			.then(function (data) {
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
			})
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		})
}

function deleteTipoParametro(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	TipoParametro.forge({ id_tipo_parametro: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrado' } 
			});

		data.save({ estatus: 0 })
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
	getTipoParametros,
	saveTipoParametro,
	getTipoParametroById,
	updateTipoParametro,
	updateTipoParametroFiltrable,
	deleteTipoParametro
}
