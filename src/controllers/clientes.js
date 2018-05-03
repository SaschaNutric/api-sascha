'use strict';

const ViewClientes  = require('../collections/v_clientes');
const ViewCliente   = require('../models/v_cliente');
const Cliente   	= require('../models/cliente');
const Bookshelf     = require('../commons/bookshelf');

function getClientes(req, res, next) {
	ViewClientes.query(function (qb) {
   		qb.where('cliente.estatus', '=', 1);
	})
	.fetch({ columns: ['id_cliente', 'cedula', 'nombres', 'apellidos', 
						'telefono', 'genero', 'estado_civil', 'direccion', 
						'fecha_nacimiento', 'tipo_cliente', 'rango_edad'] })
	.then(function(clientes) {
		if (clientes.length == 0)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay clientes registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: clientes
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}


function getClienteById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	ViewCliente.forge({ id_cliente: id })
	.fetch({ columns: ['id_cliente', 'cedula', 'nombres', 'apellidos', 
						'telefono', 'genero', 'estado_civil', 'direccion', 
						'fecha_nacimiento', 'tipo_cliente', 'rango_edad'] })
	.then(function(cliente) {
		if(!cliente) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Cliente no encontrado' } 
			});
		return res.status(200).json({ 
			error: false, 
			data: cliente  
		});
	})
	.catch(function(err){
		return res.status(500).json({ 
			error: false, 
			data: { mensaje: err.message } 
		})
	});
}

function updateCliente(req, res, next) {

const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Cliente.forge({ id_cliente: id, estatus: 1 })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ 
			nombres : req.body.nombres || data.get('nombres'),
            apellidos : req.body.apellidos || data.get('apellidos'),
            cedula : req.body.cedula || data.get('cedula'),
            fecha_nacimiento : req.body.fecha_nacimiento || data.get('fecha_nacimiento'),
            id_estado_civil : req.body.id_estado_civil || data.get('id_estado_civil'),
            id_genero : req.body.genero || data.get('id_genero'),
            telefono : req.body.telefono || data.get('telefono'),
            direccion: req.body.direccion || data.get('direccion')
		})
		.then(function() {
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


module.exports = {
	getClientes,
	getClienteById,
	updateCliente
}