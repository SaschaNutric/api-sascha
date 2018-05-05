'use strict';

const Empleados 	= require('../collections/empleados');
const Empleado  	= require('../models/empleado');

function getEmpleados(req, res, next) {
	Empleados.query(function (qb) {
   		qb.where('empleado.estatus', '=', 1);
	})
	.fetch({ columns: ['id_empleado','id_usuario','id_genero','cedula','nombres','apellidos','telefono','correo','direccion'] })
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

function saveEmpleado(req, res, next){
	console.log(JSON.stringify(req.body));

	Empleado.forge({ 
		id_usuario: req.body.id_usuario, 
		id_genero: req.body.id_genero,
		cedula: req.body.cedula,
		nombres: req.body.nombres,
		apellidos: req.body.apellidos,
		telefono: req.body.telefono,
		correo: req.body.correo,
		direccion: req.body.direccion  
	})
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

function getEmpleadoById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Empleado.forge({ id_empleado: id })
	.fetch()
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

function updateEmpleado(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Empleado.forge({ id_empleado: id })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		data.save({ id_usuario:req.body.id_usuario || data.get('id_usuario'),id_genero:req.body.id_genero || data.get('id_genero'),cedula:req.body.cedula || data.get('cedula'),nombres:req.body.nombres || data.get('nombres'),apellidos:req.body.apellidos || data.get('apellidos'),telefono:req.body.telefono || data.get('telefono'),correo:req.body.correo || data.get('correo'),direccion:req.body.direccion || data.get('direccion') })
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

function deleteEmpleado(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Empleado.forge({ id_empleado: id })
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
	getEmpleados,
	saveEmpleado,
	getEmpleadoById,
	updateEmpleado,
	deleteEmpleado
}
