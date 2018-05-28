'use strict';

const Detalle_visitas 	= require('../collections/detalle_visitas');
const Detalle_visita  	= require('../models/detalle_visita');
const VistaVisita 		= require('../models/vista_visita');

function getDetalle_visitas(req, res, next) {
	Detalle_visitas.query(function (qb) {
   		qb.where('detalle_visita.estatus', '=', 1);
	})
	.fetch({ columns: ['id_detalle_visita','id_visita','id_parametro','valor'] })
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

function saveDetalle_visita(req, res, next){
	console.log(JSON.stringify(req.body));

	Detalle_visita.forge({ id_visita:req.body.id_visita ,id_parametro:req.body.id_parametro ,valor:req.body.valor  })
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

function getDetalle_visitaById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	VistaVisita.forge({ id_visita: id })
	.fetch({ withRelated: [
		'detalles',
		'detalles.parametro',
		'detalles.parametro.tipo_parametro',
		'detalles.parametro.unidad'
	]})
	.then(function(data) {
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'dato no encontrado' } 
			});
		
		let nuevaData = data.toJSON()
		if (nuevaData.length == 0) {
			return res.status(404).json({
				error: true,
				data: { mensaje: 'Aun no tiene visitas registradas'}
			})
		}
		let _detalles = [];

		if (nuevaData.detalles && nuevaData.detalles.length > 0) {
			nuevaData.detalles.map(function (detalle) {
				if (JSON.stringify(detalle.parametro) != '{}') {
					_detalles.push({
						id_parametro: detalle.id_parametro,
						nombre: detalle.parametro.nombre,
						valor: detalle.valor,
						tipo_valor: detalle.parametro.tipo_valor,
						unidad: detalle.parametro.unidad ? detalle.parametro.unidad.nombre : null,
						unidad_abreviatura: detalle.parametro.unidad ? detalle.parametro.unidad.abreviatura : null
					});
				}
			});
		}
		
		let _data = {
				id_visita : nuevaData.id_visita,
				detalles: _detalles
			}; 

		return res.status(200).json({ 
			error : false, 
			data : _data
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function updateDetalle_visita(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Detalle_visita.forge({ id_detalle_visita: id })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ 
			id_visita:req.body.id_visita || data.get('id_visita'),
			id_parametro:req.body.id_parametro || data.get('id_parametro'),
			valor:req.body.valor || data.get('valor') 
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

function deleteDetalle_visita(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Detalle_visita.forge({ id_detalle_visita: id })
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
	getDetalle_visitas,
	saveDetalle_visita,
	getDetalle_visitaById,
	updateDetalle_visita,
	deleteDetalle_visita
}
