'use strict';

const Dietas = require('../collections/plan_dietas');

function getPlanDietas(req, res, next) {
	Dietas.query(function (q) {
        q
         .innerJoin('tipo_dieta', function () {
                this.on('plan_dieta.id_tipo_dieta', '=', 'tipo_dieta.id_tipo_dieta');
            });
	})
	.fetch({ withRelated: ['tipo_dieta'] })
	.then(function(servicios) {
		if (!servicios)
			return res.status(404).json({ 
				error: true, 
				data: { mensaje: 'No hay servicios registrados' } 
			});

		return res.status(200).json({
			error: false,
			data: servicios
		});
	})
	.catch(function (err) {
     	return res.status(500).json({
			error: true,
			data: { mensaje: err.message }
		});
    });
}

function getPlanDietaId(req, res, next) {
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


module.exports = {
	getPlanDietas,
	getPlanDietaId
}