'use strict';

const Parametro_clientes = require('../collections/parametro_clientes');
const Parametro_cliente = require('../models/parametro_cliente');

function getParametro_clientes(req, res, next) {
	Parametro_clientes.query(function (qb) {
		qb.where('parametro_cliente.estatus', '=', 1);
	})
		.fetch({
			withRelated: [
				'parametro',
				'parametro.tipo_parametro',
				'parametro.unidad'
			]
		})
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay dato registrados' }
				});
			let parametro_cliente = data.toJSON();
			let perfiles = []
			parametro_cliente.map(function (perfil) {
				if (JSON.stringify(perfil.parametro) != '{}') {
					let parametro_perfil = {
						id_parametro_cliente : perfil.id_parametro_cliente,
						id_cliente: perfil.id_cliente,
						parametro: {
							id_parametro: perfil.id_parametro,
							nombre: perfil.parametro.nombre,
							tipo_parametro: perfil.parametro.tipo_parametro.nombre,
						},
						valor: perfil.valor,
						unidad: perfil.parametro.unidad ? perfil.parametro.unidad.abreviatura : ''
					}
					perfiles.push(parametro_perfil)
				}
			})
			return res.status(200).json({
				error: false,
				data: perfiles
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}

function getParametro_clientesByIdCliente(req, res, next) {
	console.log(req.params)
	const id = Number.parseInt(req.params.id_cliente);
	if (!id || id == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});

	Parametro_clientes.query(function (qb) {
		qb.where('parametro_cliente.estatus', '=', 1);
		qb.where('parametro_cliente.id_cliente', '=', id);
	})
		.fetch({
			withRelated: [
				'parametro',
				'parametro.tipo_parametro',
				'parametro.unidad'
			]
		})
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay dato registrados' }
				});
			let parametro_cliente = data.toJSON();
			let perfiles = []
			parametro_cliente.map(function (perfil) {
				if (JSON.stringify(perfil.parametro) != '{}') {
					let abreviatura = '';
					if (perfil.parametro.id_unidad != null) {
						abreviatura = perfil.parametro.unidad.abreviatura;
					}
					let parametro_perfil = {
						id_parametro_cliente : perfil.id_parametro_cliente,
						id_cliente: perfil.id_cliente,
						parametro: {
							id_parametro: perfil.id_parametro,
							nombre: perfil.parametro.nombre,
							tipo_parametro: perfil.parametro.tipo_parametro.nombre,
						},
						valor: perfil.valor,
						unidad: abreviatura
					}
					perfiles.push(parametro_perfil)
				}
			})
			return res.status(200).json({
				error: false,
				data: perfiles
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}


function saveParametro_cliente(req, res, next) {
	console.log(JSON.stringify(req.body));
	Parametro_cliente.forge({ 
		id_cliente: req.body.id_cliente, 
		id_parametro: req.body.id_parametro, 
		valor: req.body.valor || null
	})
	.save()
	.then(function (data) {
		Parametro_cliente.forge({ id_parametro_cliente: data.get('id_parametro_cliente'), estatus: 1 })
		.fetch({
			withRelated: [
				'parametro',
				'parametro.tipo_parametro',
				'parametro.unidad',
			]
		})
		.then(function (parametro) {
			let parametro_json = parametro.toJSON();

			let nuevoParametro = {
				id_parametro_cliente: parametro_json.id_parametro_cliente,
				id_cliente: parametro_json.id_cliente,
				id_parametro: parametro_json.id_parametro,
				nombre: parametro_json.parametro.nombre,
				valor: parametro_json.valor,
				tipo_parametro: parametro_json.parametro.tipo_parametro.nombre,
				unidad: parametro_json.parametro.unidad ? parametro_json.parametro.unidad.nombre : null,
				unidad_abreviatura: parametro_json.parametro.unidad ? parametro_json.parametro.unidad.abreviatura : null,

			}
			return res.status(200).json({
				error: false,
				data: nuevoParametro
			});
		})
		.catch(function (err) {
			console.log(err.message)
			return res.status(200).json({
				error: false,
				data: data
			});
		})
	})
	.catch(function (err) {
		res.status(500)
			.json({
				error: true,
				data: { message: err.message }
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
			]
		})
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'dato no encontrado' }
				});
			return res.status(200).json({
				error: false,
				data: data
			});
		})
		.catch(function (err) {
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
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'Solicitud no encontrada' }
				});
			data.save({
				valor: req.body.valor || data.get('valor')
			})
			.tap(function (data) {
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
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'Solicitud no encontrad0' }
				});

			data.destroy()
				.then(function () {
					return res.status(200).json({
						error: false,
						data: { mensaje: 'Parametro del cliente eliminado' }
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

module.exports = {
	getParametro_clientes,
	getParametro_clientesByIdCliente,
	saveParametro_cliente,
	getParametro_clienteById,
	updateParametro_cliente,
	deleteParametro_cliente
}
