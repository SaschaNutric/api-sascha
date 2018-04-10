'use strict'

const services= require('../services')

function isAuth(req,res,next){

	console.log(" POLICIA AUTH");
	console.log(" req: "+ JSON.stringify(req.headers));
	
	if(!req.headers.authorization){
		return res.status(403)
		.json({ 
			error:true, 
			message:'Tu petición no tiene cabecera de autorización'
		});
	}
    const token = req.headers.authorization.split(" ")[1]
    services.decodeToken(token)
	.then(response=>{
		req.user = response
		next()
	})
	.catch(response=>{
		res.status(response.status)
		.json({
			error: true,
			data: { message: response.message }
		});
	})
}

module.exports=isAuth