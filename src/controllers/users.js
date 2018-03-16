var User = require('../models/user');
var Users = require('../collections/users');
var Bcrypt = require("bcrypt");
var Crypto = require("crypto");
var service = require("../services");

module.exports = {

	getUsers : function(req, res, next){
		Users.forge()
		.fetch()
		.then(function(collection){
			res.status(200)
			.json({
				error : false,
				data : collection.toJSON()
			});
		})
		.catch(function (err) {
	     	res.status(500)
			.json({
				error: true,
				data: {message: err.message}
			});
	    });
	},

	getUserById : function(req, res, next){
		User.forge({
			id : req.params.id
		})
		.fetch()
		.then(function(user){
			if(!user){
				res.status(404)
				.json({
					error : true,
					data : {}
				})
			}else{
				res.json({
					error : false,
					data : user.toJSON()
				})
			}
		})
		.catch(function(err){
			res.status(500)
			.json({
				error : false,
				data : {message : err.message}
			})
		})
	},

	saveUser :  function(req, res, next){
		var salt = Bcrypt.genSaltSync(12);
		var hash = Bcrypt.hashSync(req.body.password, salt);
		User.forge({
			name: req.body.name,
			email: req.body.email,
			password: hash
		})
		.save()
		.then(function(user){
			res.status(200).json({
				error: false,
				data: [{
					id : user.get('id'),
					name : user.get('name'),
					token : service.createToken(user)
				}]
			});
		})
		.catch(function (err) {
			res.status(500)
			.json({
				error: true,
				data: {message: err.message}
			});
		});
	},

	singIn: function(req,res){
		Users.forge().
		query(function (qb) {
		qb.where("email", "=", req.body.email.toLowerCase());
		})
		.fetchOne()
		.then(function(user){
			if(!user){
				return res.status(404).send({message:"El usuario no existe ....."})
			}
            var isPassword = Bcrypt.compareSync(req.body.password, user.get("password"))
			if(isPassword){
						res.status(200).send({message:"Te has logueado de forma exitosa",
						token: service.createToken(user)})
			}else{
				return res.status(404).send({message: "La contraseña es incorrecta"})
			}
		})
		.catch(function(err){
			res.status(500).send({message:`Ha ocurrido el siguiente error${err}`})
		})
		

	},
	updateUser : function(req, res, next){
		User.forge({ id : req.params.id })
		.fetch({ require : true })
		.then(function(user){
			user.save({
				name : req.body.name || user.get('name'),
				email : req.body.name || user.get('email')
			})
			.then(function(){
				res.json({
					error : false,
					data : { message : 'Detalles de usuario actualizado'}
				});
			})
			.catch(function(err){
				res.json({
					error : true,
					data : { message : err.message }
				})
			})
		})
		.catch(function(err){
			res.status(500)
			.json({
				error : true,
				data : {message : err.message}
			})
		})
	},

	deleteUser : function(req, res, next){
		User.forge({id : req.params.id})
		.fetch({require : true})
		.then(function(user){
			user.destroy()
			.then(function(){
				res.json({
					error : false,
					data : {message : 'Usuario eliminado de forma exitosa'}
				})
			})
			.catch(function(err){
				res.status(500)
				.json({error : true, data : {message : err.message}})
			})
		})
		.catch(function(err){
			res.status(500)
			.json({error : true, data : {message : err.message}})
		})
	}
}