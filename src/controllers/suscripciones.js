'use strict';

const Suscripcion   = require('../models/suscripcion');
const Suscripciones = require('../collections/suscripciones');
const Cliente       = require('../models/cliente');
const Bookshelf     = require('../commons/bookshelf');
const Bcrypt        = require("bcrypt");
const Crypto        = require("crypto");
const nodemailer    = require('nodemailer');
const service       = require("../services");
const MAIL_SERVICE  = process.env.MAIL_SERVICE || 'gmail';
const MAIL_USER     = process.env.MAIL_USER    || 'test.joseguerrero@gmail.com';
const MAIL_PASS     = process.env.MAIL_PASS    || '1234jose5678';

function getSuscripciones(req, res, next) {
	Suscripciones.query({ where: { estatus: 1 } })
	.fetch({ columns: ['id_suscripcion', 'correo', 'fecha_creacion', 'fecha_actualizacion', 'ultimo_acceso' ] })
	.then(function(suscripciones) {
		if (!suscripciones)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay propiedades registradas' } 
			});

		return res.status(200).json({
			error: false,
			data: suscripciones
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
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Suscripcion.forge({ id_suscripcion: id, estatus: 1 })
	.fetch()
	.then(function(suscripcion) {
		if(!suscripcion) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Suscripcion no encontrada' } 
			});
		return res.status(200).json({ 
			error : false, 
			data : suscripcion.omit('contrasenia', 'salt') 
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}


function saveSuscripcion(req, res, next) {
	Bookshelf.transaction(function(transaction) {
		const salt = Bcrypt.genSaltSync(12);
		const hash = Bcrypt.hashSync(req.body.contraseña, salt);
		const nuevaSuscripcion = {
			correo:      req.body.correo.toLowerCase(),
			contrasenia: hash,
			salt:        salt
		}

		Suscripcion.forge(nuevaSuscripcion)
		.save(null, { transacting: transaction })
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
					to: suscripcion.get('correo'),
					subject: 'Confirmación de Suscripción',
					html: `
						<h1>Bienvenido a Sascha Nutric ${cliente.get('nombres')} ${cliente.get('apellidos')}<h1>
						<p>Acceso: ${suscripcion.get('correo')}</p>
						<p>Contraseña: ${req.body.contraseña}</p>
					`
				}
				
				transportador.sendMail(opcionesCorreo)
				.then(function() {
					const suscripcionGuardada = {
						id_suscripcion: suscripcion.get('id_suscripcion'),
						correo:         suscripcion.get('correo'),
						token:          service.createToken(suscripcion),
						mensaje:        'Confirmación de correo enviada exitosamente'
					}
					transaction.commit();
					return res.status(201).json({ error: false, data: suscripcionGuardada });
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


function updateSuscripcion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Suscripcion.forge({ id_suscripcion: id, estatus: 1 })
	.fetch()
	.then(function(suscripcion){
		if(!suscripcion) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Suscripcion no encontrada' } 
			});
		suscripcion.save({
			correo:  req.body.correo || suscripcion.get('correo')
		})
		.then(function() {
			return res.status(200).json({ 
				error: false, 
				data: { mensaje: 'Suscripcion actualizada' } 
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

// Falta que elimine al cliente junto a la suscripcion
function deleteSuscripcion(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Suscripcion.forge({ id_suscripcion: id, estatus: 1 })
	.fetch()
	.then(function(suscripcion){
		console.log(suscripcion);
		if(!suscripcion) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Suscripcion no encontrada' } 
			});

		suscripcion.save({ estatus:  0 })
		.then(function() {
			return res.status(200).json({ 
				error: false,
				data: { mensaje: 'Suscripcion eliminada exitosamente' } 
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
	Suscripcion.query({ where: { correo: req.body.correo.toLowerCase(), estatus: 1 } })
	.fetch()
	.then(function(suscripcion){
		if(!suscripcion)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Correo o contraseña invalido' } 
			});
        
        const esContrasenia = Bcrypt.compareSync(req.body.contraseña, suscripcion.get('contrasenia'));
		if(esContrasenia) {
			const data = { 
				mensaje: 'Inicio de sesión exitoso',
				token: service.createToken(suscripcion)
			}
			return res.status(200).json({ 
				error: false, 
				data: data
			});
		}
		else {
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Correo o contraseña invalido' } 
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
	getSuscripciones,
	getSuscripcionById,
	saveSuscripcion,
	updateSuscripcion,
	deleteSuscripcion,
	singIn
}