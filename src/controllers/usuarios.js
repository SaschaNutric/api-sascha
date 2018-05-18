'use strict';

const Usuario       = require('../models/usuario');
const Usuarios      = require('../collections/usuarios');
const Cliente       = require('../models/cliente');
const Empleado      = require('../models/empleado');
const ViewCliente   = require('../models/v_cliente');
const correoTemplate = require('../views/correoTemplate');
const correoEmpleadoTemplate = require('../views/correoEmpleadoTemplate');
const Bookshelf     = require('../commons/bookshelf');
const Bcrypt        = require("bcryptjs");
const Crypto        = require("crypto");
const nodemailer    = require('nodemailer');
const service       = require("../services");
const MAIL_SERVICE       = process.env.MAIL_SERVICE       || 'gmail';
const MAIL_USER          = process.env.MAIL_USER          || 'saschanutric@gmail.com';
const MAIL_CLIENT_ID     = process.env.MAIL_CLIENT_ID     || '';
const MAIL_CLIENT_SECRET = process.env.MAIL_CLIENT_SECRET || '';
const REFRESH_TOKEN      = process.env.REFRESH_TOKEN      || '';

function getUsuarios(req, res, next) {
	Usuarios.query({ where: { estatus: 1 } })
	.fetch({ withRelated: ['rol'] })
	.then(function(usuarios) {
		if (!usuarios)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay usuarios registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: usuarios
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function getUsuariosEmpleados(req, res, next) {
	Usuarios.query(function(qb) {
		qb.select('*').from('usuario').innerJoin('empleado', 'usuario.id_usuario', '=', 'empleado.id_usuario');
		qb.where('tipo_usuario', '=', 2);
		qb.where('usuario.estatus', '=', 1);
	})
		.fetch({ withRelated: ['rol'] })
		.then(function (usuarios) {
			if (!usuarios)
				return res.status(404).json({
					error: true,
					data: { mensaje: 'No hay usuarios registrados' }
				});

			return res.status(200).json({
				error: false,
				data: usuarios
			});
		})
		.catch(function (err) {
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		});
}

function getUsuarioById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Usuario.forge({ id_usuario: id, estatus: 1 })
	.fetch()
	.then(function(usuario) {
		if(!usuario) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Usuario no encontrado' } 
			});
		return res.status(200).json({ 
			error : false, 
			data : usuario.omit('contrasenia', 'salt') 
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function saveUsuario(req, res, next) {
	console.log(JSON.stringify(res.boy));
	Bookshelf.transaction(function(transaction) {
		const salt = Bcrypt.genSaltSync(12);
		const hash = Bcrypt.hashSync(req.body.contraseña, salt);
		const nuevoUsuario = {
			correo:         req.body.correo.toLowerCase(),
			contrasenia:    hash,
			salt:           salt
		}

		Usuario.forge(nuevoUsuario)
		.save(null, { transacting: transaction })
		.then(function(usuario) {
			const nuevoCliente = {
				id_usuario:       usuario.get('id_usuario'),
				id_genero:        req.body.id_genero,
				id_estado_civil:  req.body.id_estado_civil,
				nombres:          req.body.nombres,
				apellidos:        req.body.apellidos,
				cedula:           req.body.cedula,
				telefono:         req.body.telefono,
				fecha_nacimiento: req.body.fecha_nacimiento,
				direccion:        req.body.direccion
			}

			Cliente.forge(nuevoCliente)
			.save(null, { transacting: transaction })
			.then(function(cliente) {		

				const transportador = nodemailer.createTransport({
					host: 'smtp.gmail.com',
					auth: {
						type: 'OAuth2',
						user:         MAIL_USER,
						clientId:     MAIL_CLIENT_ID,
						clientSecret: MAIL_CLIENT_SECRET,
						refreshToken: REFRESH_TOKEN
					}
				});

				const opcionesCorreo = {
					from: MAIL_USER,
					to: usuario.get('correo'),
					subject: 'Confirmación de Suscripción',
					html: correoTemplate(`${cliente.get('nombres')} ${cliente.get('apellidos')}`, 
										usuario.get('nombre_usuario'),
										usuario.get('correo'),
										req.body.contraseña)
				}
				
				transportador.sendMail(opcionesCorreo)
				.then(function() {
					const usuarioGuardado = {
						id_usuario:     usuario.get('id_usuario'),
						correo:         usuario.get('correo'),
						nombre_usuario: usuario.get('nombre_usuario'),
						token:          service.createToken(usuario),
						mensaje:        'Confirmación de correo enviada exitosamente'
					}
					transaction.commit();
					return res.status(201).json({ error: false, data: usuarioGuardado });
				})
				.catch(function(err) {
					transaction.rollback();
					return res.status(500).json({ error: true, data: { mensaje: err.message } });	
				});

			})
			.catch(function (err) {
				transaction.rollback();
				return res.status(500).json({ error: true, data: { mensaje: err.message } });
			});
		})
		.catch(function (err) {
			transaction.rollback();
			return res.status(500).json({ error: true, data: { mensaje: err.message } });
		});
	});
}

function saveUsuarioEmpleado(req, res, next) {
	if (!req.body.id_empleado || !req.body.id_rol || !req.body.correo || !req.body.contraseña)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Petición inválida' }
		})
	
	const salt = Bcrypt.genSaltSync(12);
	const hash = Bcrypt.hashSync(req.body.contraseña, salt);
	const nuevoUsuario = {
		correo: req.body.correo.toLowerCase(),
		contrasenia: hash,
		salt: salt,
		id_rol: req.body.id_rol,
		tipo_usuario: 2
	}

	Usuario.forge()
	.save(nuevoUsuario)
	.then(function (usuario) {
		Empleado.forge({ id_empleado: req.body.id_empleado })
		.fetch()	
		.then(function (empleado) {
			empleado.save({ id_usuario: usuario.get('id_usuario') })
			.then(function(elEmpleado) {

				const transportador = nodemailer.createTransport({
					host: 'smtp.gmail.com',
					auth: {
						type: 'OAuth2',
						user: MAIL_USER,
						clientId: MAIL_CLIENT_ID,
						clientSecret: MAIL_CLIENT_SECRET,
						refreshToken: REFRESH_TOKEN
					}
				});

				const opcionesCorreo = {
					from: MAIL_USER,
					to: usuario.get('correo'),
					subject: 'Asignación de Credenciales al Sistema',
					html: correoEmpleadoTemplate(`${elEmpleado.get('nombres')} ${elEmpleado.get('apellidos')}`,
						usuario.get('correo'),
						req.body.contraseña)
				}

				transportador.sendMail(opcionesCorreo)
				.then(function () {
					const usuarioGuardado = {
						id_usuario: usuario.get('id_usuario'),
						correo: usuario.get('correo'),
						empleado:elEmpleado,
						mensaje: 'Confirmación de correo enviada exitosamente'
					}
					return res.status(201).json({ error: false, data: usuarioGuardado });
				})
				.catch(function (err) {
					return res.status(500).json({ error: true, data: { mensaje: err.message } });
				});
			})
			.catch(function (err) {
				return res.status(500).json({ error: true, data: { mensaje: err.message } });
			});
		})
		.catch(function (err) {
			return res.status(500).json({ error: true, data: { mensaje: err.message } });
		});
	})
	.catch(function (err) {
		return res.status(500).json({ error: true, data: { mensaje: err.message } });
	});
}

function updateUsuario(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	if(!req.body.id_rol)
		return res.status(400).json({
			error: true,
			data: { mensaje: 'Solicitud incorrecta' }
		});

	Usuario.forge({ id_usuario: id, estatus: 1 })
	.fetch()
	.then(function(usuario){
		if(!usuario) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Usuario no encontrado' } 
			});
		usuario.save({
			id_rol:  req.body.id_rol || usuario.get('id_rol')
		})
		.then(function(usuario) {
			return res.status(200).json({ 
				error: false, 
				data: usuario.omit('contrasenia', 'salt')
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

function deleteUsuario(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Usuario.forge({ id_usuario: id, estatus: 1 })
	.fetch()
	.then(function(usuario){
		if(!usuario) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Usuario no encontrad0' } 
			});

		usuario.save({ estatus:  0 })
		.then(function() {
			return res.status(200).json({ 
				error: false,
				data: { mensaje: 'Usuario eliminado exitosamente' } 
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

function singIn(req, res) {
	if(!req.body.correo && !req.body.nombre_usuario)
		return res.status(400).json({ error: true, data: { mensaje: 'Faltan parametros en el body' } });
	
	let credenciales = {
		correo: req.body.correo ? req.body.correo.toLowerCase() : null,
		nombre_usuario: req.body.nombre_usuario ? req.body.nombre_usuario.toLowerCase() : null
	}
	Usuario.query(function(qb) { 
		qb.where('correo', credenciales.correo).orWhere('nombre_usuario', credenciales.nombre_usuario);
		qb.where('tipo_usuario', '=', 1);
		qb.where('estatus', 1); 
	})
	.fetch()
	.then(function(usuario){
		if(!usuario)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Nombre de usuario o Correo inválido' } 
			});
        
        const esContrasenia = Bcrypt.compareSync(req.body.contraseña, usuario.get('contrasenia'));
		if(esContrasenia) {
			ViewCliente.forge({ id_usuario: usuario.get('id_usuario') })
			.fetch({ columns: ['id_cliente', 'cedula', 'nombres', 'apellidos', 
								'telefono', 'id_genero', 'genero', 'id_estado_civil','estado_civil', 'direccion', 
								'fecha_nacimiento', 'tipo_cliente', 'rango_edad'] })
			.then(function(cliente) {
				if(!cliente) 
					return res.status(404).json({ 
						error: true, 
						data: { mensaje: 'Cliente no encontrado' } 
					});
				const data = { 
					mensaje: 'Inicio de sesión exitoso',
					token: service.createToken(usuario),
					cliente: cliente
				}
				return res.status(200).json({ 
					error: false, 
					data: data
				});
			})
			.catch(function(err){
				return res.status(500).json({ 
					error: false, 
					data: { mensaje: err.message } 
				})
			});
		}
		else {
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'contraseña inválida' } 
			});
		}
	})
	.catch(function(err){
		console.log(err.mensaje);
		return res.status(500).json({ 
			error: true, 
			data: { mensaje: err.message } 
		});
	})
}


function singInEmpleado(req, res) {
	if (!req.body.correo && !req.body.nombre_usuario)
		return res.status(400).json({ error: true, data: { mensaje: 'Faltan parametros en el body' } });

	let credenciales = {
		correo: req.body.correo ? req.body.correo.toLowerCase() : null,
		nombre_usuario: req.body.nombre_usuario ? req.body.nombre_usuario.toLowerCase() : null
	}
	Usuario.query(function (qb) {
		qb.where('correo', credenciales.correo);
		qb.where('contrasenia', req.body.contraseña);
		qb.where('tipo_usuario', 2);
		qb.where('estatus', 1);
	})
	.fetch()
	.then(function (usuario) {
		if (!usuario)
			return res.status(404).json({
				error: true,
				data: { mensaje: 'Correo o contraseña inválido' }
			});
			Empleado.forge({ id_usuario: usuario.get('id_usuario') })
			.fetch()
			.then(function (empleado) {
				if (!empleado)
					return res.status(404).json({
						error: true,
						data: { mensaje: 'Empleado no encontrado' }
					});
				const data = {
					mensaje: 'Inicio de sesión exitoso',
					token: service.createToken(usuario),
					empleado: empleado
				}
				return res.status(200).json({
					error: false,
					data: empleado
				});
			})
			.catch(function (err) {
				return res.status(500).json({
					error: false,
					data: { mensaje: err.message }
				})
			});
	})
	.catch(function (err) {
		console.log(err.mensaje);
		return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
	})
}

module.exports = {
	getUsuarios,
	getUsuarioById,
	getUsuariosEmpleados,
	saveUsuario,
	saveUsuarioEmpleado,
	updateUsuario,
	deleteUsuario,
	singIn,
	singInEmpleado
}
