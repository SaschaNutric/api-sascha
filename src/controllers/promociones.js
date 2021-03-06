'use strict';
const Bookshelf = require('../commons/bookshelf');
const Promociones = require('../collections/promociones');
const Promocion = require('../models/promocion');
const cloudinary = require('../../cloudinary');
const moment     = require('moment');

function getPromociones(req, res, next) {
	Promociones.query(function (qb) {
		qb.where('promocion.estatus', '=', 1);
		qb.orderBy('promocion.valido_hasta', 'DESC');
		
	})
		.fetch({
			withRelated: [
				'servicio',
				'genero',
				'estado_civil',
				'rango_edad',
				'parametros',
				'parametros.parametro'
			]
		})
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay dato registrados' }
				});

			let dataJSON = data.toJSON().map(function (promocion) {
				let parametros = [];
				promocion.parametros.map(function (parametro) {
					if (parametro.estatus == 1) {
						parametros.push({
							id_parametro_promocion: parametro.id_parametro_promocion,
							nombre: parametro.parametro.nombre,
							valor_minimo: parametro.valor_minimo,
							valor_maximo: parametro.valor_maximo
						})
					}
				})
				let validoDesde = JSON.stringify(promocion.valido_desde);
				let validoHasta = JSON.stringify(promocion.valido_hasta);
				promocion.valido_desde = validoDesde.substr(1, 10);
				promocion.valido_hasta = validoHasta.substr(1, 10);
				promocion.parametros = parametros;
				return promocion;
			});
			return res.status(200).json({
				error: false,
				data: dataJSON
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}

function getPromocionesValidas(req, res, next) {
	Promociones.query(function (qb) {
		qb.where('promocion.estatus', '=', 1);
		qb.where('promocion.valido_desde', '<=', 'now()')
		  .andWhere('promocion.valido_hasta', '>=', 'now()');
		qb.orderBy('promocion.valido_hasta', 'ASC');
	})
		.fetch({
			withRelated: [
				'servicio',
				'servicio.plan_dieta',
				'servicio.plan_ejercicio',
				'servicio.plan_suplemento',
				'genero',
				'estado_civil',
				'rango_edad',
				'parametros',
				'parametros.parametro'
			]
		})
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay dato registrados' }
				});

			let dataJSON = data.toJSON().map(function (promocion) {
				let parametros = [];
				promocion.parametros.map(function (parametro) {
					if (parametro.estatus == 1) {
						parametros.push({
							id_parametro_promocion: parametro.id_parametro_promocion,
							nombre: parametro.parametro.nombre,
							valor_minimo: parametro.valor_minimo,
							valor_maximo: parametro.valor_maximo
						})
					}
				})
				let validoDesde = JSON.stringify(promocion.valido_desde);
				let validoHasta = JSON.stringify(promocion.valido_hasta);
				promocion.valido_desde = validoDesde.substr(1, 10);
				promocion.valido_hasta = validoHasta.substr(1, 10);
				promocion.parametros = parametros;
				return promocion;
			});
			return res.status(200).json({
				error: false,
				data: dataJSON
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}

function savePromocion(req, res, next) {
	console.log(JSON.stringify(req.body));
	if (req.files.imagen) {
		const imagen = req.files.imagen
		cloudinary.uploader.upload(imagen.path, function (result) {
			if (result.error) {
				return res.status(500).json({
					error: true,
					data: { message: result.error }
				});
			}
			Promocion.forge({
				id_servicio: req.body.id_servicio,
				nombre: req.body.nombre,
				descripcion: req.body.descripcion,
				descuento: req.body.descuento,
				url_imagen: result.url,
				id_genero: req.body.id_genero,
				id_estado_civil: req.body.id_estado_civil,
				id_rango_edad: req.body.id_rango_edad,
				valido_desde: req.body.valido_desde,
				valido_hasta: req.body.valido_hasta
			})
				.save()
				.then(function (servicio) {
					res.status(200).json({
						error: false,
						data: servicio
					});
				})
				.catch(function (err) {
					res.status(500).json({
						error: true,
						data: { message: err.message }
					});
				});
		});
	}
	else {
		Promocion.forge({
			id_servicio: req.body.id_servicio,
			nombre: req.body.nombre,
			descripcion: req.body.descripcion,
			descuento: req.body.descuento,
			url_imagen: 'https://res.cloudinary.com/saschanutric/image/upload/v1525906759/latest.png',
			id_genero: req.body.id_genero,
			id_estado_civil: req.body.id_estado_civil,
			id_rango_edad: req.body.id_rango_edad,
			valido_desde: req.body.valido_desde,
			valido_hasta: req.body.valido_hasta
		})
			.save()
			.then(function (servicio) {
				res.status(200).json({
					error: false,
					data: servicio
				});
			})
			.catch(function (err) {
				res.status(500).json({
					error: true,
					data: { message: err.message }
				});
			});
	}
}

function sendPromocion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (id == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	Promocion.forge({ id_promocion: id, estatus: 1 })
	.fetch()
	.then(function(data) {
		if(!data)
			res.status(404).json({
				error: true,
				data: { mensaje: 'Promoción no encontrada' }
			});
		let promocion = data.toJSON();

		if(moment().isAfter(moment(promocion.valido_hasta))) {
			res.status(404).json({
				error: false,
				data: { mensaje: 'Promoción vencida, no puede ser difundida' }
			})
		}
		else {
			Bookshelf.knex.raw(`SELECT fun_promocion_cliente(${id})`)
			.then(function(data) {
				res.status(200).json({
					error: false,
					data: { mensaje: 'Promoción difundida satisfactoriamente' }
				})		
			})
			.catch(function(err) {
				res.status(500).json({
					error: true,
					data: { mensaje: err.message }
				})
			})
		}
	})
	.catch(function(err) {
		res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		})
	});
}

function getPromocionById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});

	Promocion.forge({ id_promocion: id, estatus: 1 })
		.fetch({
			withRelated: [
				'servicio',
				'genero',
				'estado_civil',
				'rango_edad',
				'parametros',
				'parametros.parametro'
			]
		})
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'dato no encontrado' }
				});
			let promocion = data.toJSON();
			let parametros = [];
			promocion.parametros.map(function (parametro) {
				if (parametro.estatus == 1) {
					parametros.push({
						id_parametro_promocion: parametro.id_parametro_promocion,
						nombre: parametro.parametro.nombre,
						valor_minimo: parametro.valor_minimo,
						valor_maximo: parametro.valor_maximo
					})
				}
			})
			let validoDesde = JSON.stringify(promocion.valido_desde);
			let validoHasta = JSON.stringify(promocion.valido_hasta);
			promocion.valido_desde = validoDesde.substr(1, 10);
			promocion.valido_hasta = validoHasta.substr(1, 10);
			promocion.parametros = parametros;


			return res.status(200).json({
				error: false,
				data: promocion
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: false,
				data: { mensaje: err.message }
			})
		});
}

function updatePromocion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	}

	Promocion.forge({ id_promocion: id, estatus: 1 })
		.fetch()
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'Solicitud no encontrada' }
				});
			if (req.files.imagen && req.files.imagen.name != data.get('url_imagen').substr(65)) {
				const imagen = req.files.imagen
				cloudinary.uploader.upload(imagen.path, function (result) {
					if (result.error) {
						return res.status(500).json({
							error: true,
							data: { message: result.error }
						});
					}
					data.save({
						id_servicio: req.body.id_servicio || data.get('id_servicio'),
						nombre: req.body.nombre || data.get('nombre'),
						descripcion: req.body.descripcion || data.get('descripcion'),
						descuento: req.body.descuento || data.get('descuento'),
						url_imagen: result.url,
						id_genero: req.body.id_genero || data.get('id_genero'),
						id_estado_civil: req.body.id_estado_civil || data.get('id_estado_civil'),
						id_rango_edad: req.body.id_rango_edad || data.get('id_rango_edad'),
						valido_desde: req.body.valido_desde || data.get('valido_desde'),
						valido_hasta: req.body.valido_hasta || data.get('valido_hasta')
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
				});
			} else {
				data.save({
					id_servicio: req.body.id_servicio || data.get('id_servicio'),
					nombre: req.body.nombre || data.get('nombre'),
					descripcion: req.body.descripcion || data.get('descripcion'),
					descuento: req.body.descuento || data.get('descuento'),
					url_imagen: req.body.url_imagen || data.get('url_imagen'),
					id_genero: req.body.id_genero || data.get('id_genero'),
					id_estado_civil: req.body.id_estado_civil || data.get('id_estado_civil'),
					id_rango_edad: req.body.id_rango_edad || data.get('id_rango_edad'),
					valido_desde: req.body.valido_desde || data.get('valido_desde'),
					valido_hasta: req.body.valido_hasta || data.get('valido_hasta')
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
			}
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		})
}

function deletePromocion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	}
	Promocion.forge({ id_promocion: id, estatus: 1 })
		.fetch()
		.then(function (data) {
			if (!data)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'Solicitud no encontrad0' }
				});

			data.save({ estatus: 0 })
				.then(function () {
					return res.status(200).json({
						error: false,
						data: { mensaje: 'Registro eliminado' }
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
	getPromociones,
	getPromocionesValidas,
	savePromocion,
	sendPromocion,
	getPromocionById,
	updatePromocion,
	deletePromocion
}