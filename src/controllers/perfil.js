'use strict';

const EstadosCivil  = require('../collections/estado_civil');
const Generos       = require('../collections/generos');
const Bookshelf     = require('../commons/bookshelf');
const service       = require("../services");

function getEstados(req, res, next) {
	Estados.query({ where: { estatus: 1 } })
	.fetch({ columns: ['id_estado', 'nombre'] })
	.then(function(estados) {
		if (!estados)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay estados registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: estados
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function getEstadosCivil(req, res, next) {
	EstadosCivil.query({})
	.fetch({ columns: ['id_estado_civil', 'nombre'] })
	.then(function(estadosCivil) {
		if (!estadosCivil)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay estados civil registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: estadosCivil
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}


function getGeneros(req, res, next) {
	Generos.query({})
	.fetch({ columns: ['id_genero', 'nombre'] })
	.then(function(generos) {
		if (!generos)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay generos registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: generos
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}


module.exports = {
	getGeneros,
	getEstados,
	getEstadosCivil
}