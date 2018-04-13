'use strict';

const Usuario       = require('../models/usuario');
const Usuarios      = require('../collections/usuarios');
const Cliente       = require('../models/cliente');
const Bookshelf     = require('../commons/Bookshelf');
const Bcrypt        = require("bcrypt");
const Crypto        = require("crypto");
const nodemailer    = require('nodemailer');
const service       = require("../services");
const MAIL_SERVICE  = process.env.MAIL_SERVICE || 'gmail';
const MAIL_USER     = process.env.MAIL_USER    || 'test.joseguerrero@gmail.com';
const MAIL_PASS     = process.env.MAIL_PASS    || '1234jose5678';

function getUsuarios(req, res, next) {
	Usuarios.query({ where: { estatus: 1 } })
	.fetch({ columns: ['id_usuario', 'correo', 'nombre_usuario', 'fecha_creacion', 'fecha_actualizacion', 'ultimo_acceso' ] })
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
	Bookshelf.transaction(function(transaction) {
		const salt = Bcrypt.genSaltSync(12);
		const hash = Bcrypt.hashSync(req.body.contraseña, salt);
		const nuevoUsuario = {
			correo:         req.body.correo.toLowerCase(),
			nombre_usuario: req.body.nombre_usuario.toLowerCase(),
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
				id_estado:        req.body.id_estado,
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
					service: MAIL_SERVICE,
					auth: {
						user: MAIL_USER,
						pass: MAIL_PASS
					}
				});

				const opcionesCorreo = {
					from: MAIL_USER,
					to: usuario.get('correo'),
					subject: 'Confirmación de Suscripción',
					html: `
						<h1>Bienvenido a Sascha Nutric ${cliente.get('nombres')} ${cliente.get('apellidos')}<h1>
						<p>Acceso: ${usuario.get('correo')} o ${usuario.get('nombre_usuario')}</p>
						<p>Contraseña: ${req.body.contraseña}</p>
					`
				}
				
				transportador.sendMail(opcionesCorreo)
				.then(function() {
					const usuarioGuardado = {
						id_usuario:     usuario.get('id_suscripcion'),
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


function updateUsuario(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Usuario.forge({ id_suscripcion: id, estatus: 1 })
	.fetch()
	.then(function(usuario){
		if(!usuario) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Usuario no encontrada' } 
			});
		usuario.save({
			correo:  req.body.correo || usuario.get('correo')
		})
		.then(function() {
			return res.status(200).json({ 
				error: false, 
				data: { mensaje: 'Usuario actualizada' } 
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
	Usuario.query(function(qb) { 
		qb.where('correo', req.body.correo.toLowerCase()).orWhere('nombre_usuario', req.body.correo.toLowerCase());
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
			const data = { 
				mensaje: 'Inicio de sesión exitoso',
				token: service.createToken(usuario)
			}
			return res.status(200).json({ 
				error: false, 
				data: data
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
		return res.status(500).json({ 
			error: true, 
			data: { mensaje: err.message } 
		});
	})
}


module.exports = {
	getUsuarios,
	getUsuarioById,
	saveUsuario,
	updateUsuario,
	deleteUsuario,
	singIn
}