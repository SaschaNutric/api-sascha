'use strict';

const Suscripcion   = require('../models/suscripcion');
const Suscripciones = require('../collections/suscripciones');
const Cliente       = require('../models/cliente');
const Bookshelf     = require('../commons/Bookshelf');
const Bcrypt        = require("bcrypt");
const Crypto        = require("crypto");
const nodemailer    = require('nodemailer');
const service       = require("../services");

function getSuscripciones(req, res, next) {
	Suscripciones.query({ where: { estatus: 1 } }).fetch()
	.then(function(suscripciones){
		if (!suscripciones)
			return res.status(404).json({ 
						error: true, 
						data: { mensaje: 'No hay propiedades registradas' } 
					});

		return res.status(200).json({
					error: false,
					data: suscripciones.toJSON()
				});
	})
	.catch(function (err) {
     	return res.status(500).json({
					error: true,
					data: { mensaje: err.message }
				});
    });
}

function getSuscripcionById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ error: true, data: { mensaje: 'Solicitud incorrecta' } });
	Suscripcion.forge({ id_suscripcion: id, estatus: 1 })
	.fetch()
	.then(function(suscripcion) {
		if(!suscripcion) 
			return res.status(404).json({ error: true, data: { mensaje: 'Suscripcion no encontrada' } });
		return res.status(200).json({ error : false, data : user.toJSON() })
	})
	.catch(function(err){
		return res.status(500).json({ error: false, data: { mensaje: err.message } })
	});
}

function sendConfirmacion(nombre, correo, contraseña) {
	const transportador = nodemailer.createTransport({
		service: 'gmail',
		auth: {
			user: 'test.joseguerrero@gmail.com',
			pass: '1234jose5678'
		}
	});

	const opcionesCorreo = {
		from: 'test.joseguerrero@gmail.com',
		to: correo,
		subject: 'Confirmación de Suscripción',
		html: `
			<h1>Bienvenido a Sascha Nutric ${nombre}<h1>
			<p>Acceso: ${correo}</p>
			<p>Contraseña: ${contraseña}</p>
		`
	}

	transportador.sendMail(opcionesCorreo, function(req, res) {
		/*
		if (err) 
			return res.status(500).json({
				error: true,
				data: { mensaje: err.message }
			});
		else 
			return res.status(200).json({
				error: false,
				data: { mensaje: 'Mensaje enviado satisfactoriamente' }
			});
		*/
	});
}

function saveSuscripcion(req, res, next) {
	Bookshelf.transaction(function(tr) {
		const salt = Bcrypt.genSaltSync(12);
		const hash = Bcrypt.hashSync(req.body.contraseña, salt);
		const nuevaSuscripcion = {
			correo:      req.body.correo.toLowerCase(),
			contrasenia: hash,
			salt:        salt
		}

		Suscripcion.forge(nuevaSuscripcion)
		.save(null, { transacting: tr })
		.then(function(suscripcion) {
			const nuevoCliente = {
				id_suscripcion:   suscripcion.get('id_suscripcion'),
				nombres:          req.body.nombres,
				apellidos:        req.body.apellidos,
				cedula:           req.body.cedula,
				telefono:         req.body.telefono,
				fecha_nacimiento: req.body.fecha_nacimiento,
				direccion:        req.body.direccion
			//	sexo:             req.body.sexo 
			}
			Cliente.forge(nuevoCliente)
			.save(null, { transacting: tr })
			.then(function(cliente) {		
				/* sendConfirmacion(`${cliente.get('nombres')} ${cliente.get('apellidos')}`,
								 suscripcion.get('correo'),
					             req.body.contraseña);
				*/
				const transportador = nodemailer.createTransport({
					service: 'gmail',
					auth: {
						user: 'test.joseguerrero@gmail.com',
						pass: '1234jose5678'
					}
				});

				const opcionesCorreo = {
					from: 'test.joseguerrero@gmail.com',
					to: correo,
					subject: 'Confirmación de Suscripción',
					html: `
						<h1>Bienvenido a Sascha Nutric ${nombre}<h1>
						<p>Acceso: ${correo}</p>
						<p>Contraseña: ${contraseña}</p>
					`
				}

				transportador.sendMail(opcionesCorreo, function(req, res) {
					if (err) {
						tr.rollback();
						return res.status(500).json({
							error: true,
							data: { mensaje: err.message }
						});
					}
				});

				const suscripcionGuardada = {
					id_suscripcion: suscripcion.get('id_suscripcion'),
					correo:         suscripcion.get('correo'),
					token:          service.createToken(suscripcion),
					mensaje:        'Confirmación de correo enviada exitosamente'
				}

				return res.status(201).json({ error: false, data: suscripcionGuardada });
			})
			.catch(function (err) {
				tr.rollback();
				return res.status(500).json({ error: true, data: { mensaje: err.message } });
			});
		})
		.catch(function (err) {
			tr.rollback();
			return res.status(500).json({ error: true, data: { mensaje: err.message } });
		});
		
	})
}

function singIn(req, res) {
	Suscripcion.forge()
	.query(function (qb) {
		qb.where("correo", "=", req.body.correo.toLowerCase());
	})
	.fetchOne()
	.then(function(suscripcion){
		if(!suscripcion)
			return res.status(404).json({ error: true, data: { mensaje: 'Correo o contraseña incorrectos' } });
        
        const esContrasenia = Bcrypt.compareSync(req.body.contraseña, suscripcion.get('contrasenia'));
		if(esContrasenia) {
			const data = { 
				mensaje: 'Inicio de sesión exitoso',
				token: service.createToken(suscripcion)
			}
			return res.status(200).json({ error: false, data: data});
		}
		else {
			return res.status(404).json({ error: true, data: { mensaje: 'Correo o contraseña incorrectos' } });
		}
	})
	.catch(function(err){
		return res.status(500).json({ error: true, data: { mensaje: err.message } });
	})
	
}

function updateSuscripcion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ error: true, data: { mensaje: 'Solicitud incorrecta' } });
	}
	Suscripcion.forge({ id_suscripcion: id, estatus: 1 })
	.fetch({ require: true })
	.then(function(suscripcion){
		suscripcion.save({
			correo:  req.body.correo || suscripcion.get('correo')
		})
		.then(function() {
			return res.status(200).json({ error: false, data: { mensaje: 'Detalles de suscripcion actualizado' } });
		})
		.catch(function(err) {
			return res.status(500).json({ error : true, data : { mensaje : err.message } });
		})
	})
	.catch(function(err) {
		return res.status(500).json({ error : true, data : { mensaje : err.message } });
	})
}

function deleteSuscripcion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ error: true, data: { mensaje: 'Solicitud incorrecta' } });
	}
	Suscripcion.forge({ id_suscripcion: id, estatus: 1 })
	.fetch({ require: true })
	.then(function(suscripcion){
		suscripcion.save({ estatus:  0 })
		.then(function() {
			return res.status(200).json({ error: false, data: { mensaje: 'Suscripcion eliminada exitosamente' } });
		})
		.catch(function(err) {
			return res.status(500).json({ error: true, data: { mensaje: err.message} });
		})
	})
	.catch(function(err){
		return res.status(500).json({ error: true, data: { mensaje: err.message } });
	})
}

module.exports = {
	getSuscripciones,
	getSuscripcionById,
	saveSuscripcion,
	updateSuscripcion,
	deleteSuscripcion,
	singIn
}