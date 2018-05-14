'use strict';

const Parametro_clientes 	= require('../collections/parametro_clientes');
const Parametro_cliente  	= require('../models/parametro_cliente');

function getParametro_clientes(req, res, next) {
	Parametro_clientes.query(function (qb) {
   		qb.where('parametro_cliente.estatus', '=', 1);
	})
	.fetch({
		withRelated: [
			'parametro',
			'parametro.tipo_parametro',
			'parametro.unidad',
			'parametro.unidad.tipo_unidad',
			'cliente',
			'cliente.estado',
			'cliente.estado_civil',
			'cliente.rango_edad'
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
			data: { mensaje: err.message }
		});
    });
}

function saveParametro_cliente(req, res, next){
	console.log(JSON.stringify(req.body));

	Parametro_cliente.forge({ id_cliente:req.body.id_cliente ,id_parametro:req.body.id_parametro ,valor:req.body.valor  })
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

function getParametro_clienteById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Parametro_cliente.forge({ id_parametro_cliente: id, estatus: 1 })
	.fetch({
		withRelated: [
			'parametro',
			'parametro.tipo_parametro',
			'parametro.unidad',
			'parametro.unidad.tipo_unidad',
			'cliente',
			'cliente.estado',
			'cliente.estado_civil',
			'cliente.rango_edad'
		]})
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

function updateParametro_cliente(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Parametro_cliente.forge({ id_parametro_cliente: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ 
			id_cliente:req.body.id_cliente || data.get('id_cliente'),
			id_parametro:req.body.id_parametro || data.get('id_parametro'),
			valor:req.body.valor || data.get('valor') 
		})
		.fetch({
		withRelated: [
			'parametro',
			'parametro.tipo_parametro',
			'parametro.unidad',
			'parametro.unidad.tipo_unidad',
			'cliente',
			'cliente.estado',
			'cliente.estado_civil',
			'cliente.rango_edad'
		]})
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

function deleteParametro_cliente(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Parametro_cliente.forge({ id_parametro_cliente: id, estatus: 1 })
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
	getParametro_clientes,
	saveParametro_cliente,
	getParametro_clienteById,
	updateParametro_cliente,
	deleteParametro_cliente
}
