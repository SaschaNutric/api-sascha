'use strict';

const Bookshelf         = require('../commons/bookshelf');
const Regimen_dietas 	= require('../collections/regimen_dietas');
const Regimen_dieta  	= require('../models/regimen_dieta');
const DetalleRegimenAlimentos = require('../collections/detalle_regimen_alimentos');

function getRegimen_dietas(req, res, next) {
	Regimen_dietas.query(function (qb) {
   		qb.where('regimen_dieta.estatus', '=', 1);
	})
	.fetch({ columns: ['id_regimen_dieta','id_detalle_plan_dieta','id_cliente','cantidad'] })
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

function saveRegimen_dieta(req, res, next){
	console.log(JSON.stringify(req.body));

	Regimen_dieta.forge({ 
		id_detalle_plan_dieta:req.body.id_detalle_plan_dieta ,
		id_cliente:req.body.id_cliente ,
		cantidad:req.body.cantidad  
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

function getRegimen_dietaById(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') 
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});

	Regimen_dieta.forge({ id_regimen_dieta })
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

function updateRegimen_dieta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}

	Regimen_dieta.forge({ id_regimen_dieta: id })
	.fetch()
	.then(function(data){
		if(!data) 
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'Solicitud no encontrada' } 
			});
		Bookshelf.transaction(function(t) {
			data.save(
				{ cantidad: req.body.cantidad || data.get('cantidad') },
				{ transacting: t }
			)
			.tap(function(regimen) {
				let regimen_json = regimen.toJSON();
				DetalleRegimenAlimentos.query(function(qb) {
					qb.where('id_regimen_dieta', '=', regimen_json.id_regimen_dieta).delete();
				})
				.fetch()
				.then(function() {
					let alimentos = []
					req.body.alimentos.map(function (alimento) {
						alimentos.push({
							id_alimento: alimento.id_alimento,
							id_regimen_dieta: regimen_json.id_regimen_dieta
						})
					})

					let regimen_alimentos = DetalleRegimenAlimentos.forge(alimentos);
					regimen_alimentos.invokeThen('save', null, { transacting: t })
					.then(function () {
						let data = {
							id_regimen_dieta: regimen_json.id_regimen_dieta,
							cantidad: regimen_json.cantidad,
							alimentos: regimen_alimentos
						}
						t.commit();
						return res.status(200).json({
							error: false,
							data: data
						});
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
			.catch(function(err) {
				t.rollback();
				return res.status(500).json({ 
					error : true, 
					data : { mensaje : err.message } 
				});
			})
		});
	})
	.catch(function(err) {
		return res.status(500).json({ 
			error : true, 
			data : { mensaje : err.message } 
		});
	})
}

function deleteRegimen_dieta(req, res, next) {
	const id = Number.parseInt(req.params.id);
	if (!id || id == 'NaN') {
		return res.status(400).json({ 
			error: true, 
			data: { mensaje: 'Solicitud incorrecta' } 
		});
	}
	Regimen_dieta.forge({ id_regimen_dieta : id })
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
	getRegimen_dietas,
	saveRegimen_dieta,
	getRegimen_dietaById,
	updateRegimen_dieta,
	deleteRegimen_dieta
}
