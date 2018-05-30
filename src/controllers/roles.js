'use strict';
const Bookshelf = require('../commons/bookshelf');
const Roles = require('../collections/roles');
const Rol = require('../models/rol');
const RolFuncionalidades = require('../collections/rol_funcionalidades');


function getRoles(req, res, next) {
	Roles.query(function (qb) {
		qb.where('rol.estatus', '=', 1);
	})
		.fetch({ withRelated: ['funcionalidades'] })
		.then(function (data) {
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

function saveRol(req, res, next) {
	console.log(JSON.stringify(req.body));
	Bookshelf.transaction(function (t) {
		Rol.forge({ nombre: req.body.nombre, descripcion: req.body.descripcion })
			.save(null, { transacting: t })
			.then(function (rol) {
				let rol_json = rol.toJSON();
				let funcionalidades = []
				req.body.funcionalidades.map(function (funcionalidad) {
					funcionalidades.push({
						id_rol: rol_json.id_rol,
						id_funcionalidad: funcionalidad.id_funcionalidad
					})
				})
				let rol_funcionalidad = RolFuncionalidades.forge(funcionalidades);
				rol_funcionalidad.invokeThen('save', null, { transacting: t })
					.then(function () {
						t.commit();
						Rol.forge({ id_rol: rol_json.id_rol, estatus: 1 })
							.fetch({ withRelated: ['funcionalidades'] })
							.then(function (rolNuevo) {
								return res.status(200).json({
									error: false,
									data: rolNuevo
								});
							}).catch(function (err) {
								return res.status(404).json({
									error: true,
									data: { mensaje: err.message }
								})
							})
					})
					.catch(function (err) {
						t.rollback()
						return res.status(500).json({
							error: true,
							data: { mensaje: err.message }
						})
					})

			})
			.catch(function (err) {
				t.rollback()
				res.status(500)
					.json({
						error: true,
						data: { message: err.message }
					});
			});
	})

}

function getRolById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN')
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});

	Rol.forge({ id_rol: id, estatus: 1 })
		.fetch()
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

function updateRol(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	}
	Bookshelf.transaction(function (t) {
		Rol.forge({ id_rol: id, estatus: 1 })
			.fetch()
			.then(function (data) {
				if (!data)
					return res.status(404).json({
						error: true,
						data: { mensaje: 'Solicitud no encontrada' }
					});
				data.save({ nombre: req.body.nombre || data.get('nombre'), descripcion: req.body.descripcion || data.get('descripcion') }, { transacting: t })
					.then(function (rol) {
						let rol_json = rol.toJSON();
						RolFuncionalidades.query(function (qb) {
							qb.where('id_rol', '=', rol_json.id_rol).delete();
						})
							.fetch()
							.then(function () {
								let funcionalidades = []
								req.body.funcionalidades.map(function (funcionalidad) {
									funcionalidades.push({
										id_rol: rol_json.id_rol,
										id_funcionalidad: funcionalidad.id_funcionalidad
									})
								})
								let rol_funcionalidad = RolFuncionalidades.forge(funcionalidades);
								rol_funcionalidad.invokeThen('save', null, { transacting: t })
									.then(function () {
										t.commit();
										Rol.forge({ id_rol: rol_json.id_rol, estatus: 1 })
											.fetch({ withRelated: ['funcionalidades'] })
											.then(function (rolNuevo) {
												return res.status(200).json({
													error: false,
													data: rolNuevo
												});
											}).catch(function (err) {
												return res.status(404).json({
													error: true,
													data: { mensaje: err.message }
												})
											})
									})
									.catch(function (err) {
										t.rollback()
										return res.status(500).json({
											error: true,
											data: { mensaje: err.message }
										})
									})

							})
							.catch(function (err) {
								t.rollback()
								return res.status(500).json({
									error: true,
									data: { mensaje: err.message }
								})
							})

					})
					.catch(function (err) {
						t.rollback()
						return res.status(500).json({
							error: true,
							data: { mensaje: err.message }
						});
					})
			})
			.catch(function (err) {
				t.rollback()
				return res.status(500).json({
					error: true,
					data: { mensaje: err.message }
				});
			})
	})
}

function deleteRol(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});
	}
	Rol.forge({ id_rol: id, estatus: 1 })
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
	getRoles,
	saveRol,
	getRolById,
	updateRol,
	deleteRol
}
