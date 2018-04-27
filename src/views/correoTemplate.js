'use strict'
const logo = __dirname + '/../../public/images/logo-inmobiliaria.jpg';

function correoTemplate(nombre, nombre_usuario, correo, contraseña) {
	
	return `
		<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Correo Contacto Web Ramirez Serra</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
</head>
<body style="margin: 0; padding: 0;">
 
	 <table border="0" cellpadding="0" cellspacing="0" width="95%" style="max-width: 700px; margin: 30px auto; border: 5px solid #7ab740; -webkit-box-shadow: 4px 7px 14px -1px rgba(99,99,99,1);
-moz-box-shadow: 4px 7px 14px -1px rgba(99,99,99,1);
box-shadow: 4px 7px 14px -1px rgba(99,99,99,1);">
	 
		<tr style="border:none;">
		 
		 	<td width="10%"  style="border:none">
		 
		 
			 </td>

			 <td>
		            <center><img src="https://res.cloudinary.com/saschanutric/image/upload/v1524779283/logosascha.png" style="max-width:280px"></center>
		 			 <h1 style="color:#3da3cb">
		 			      <center style="font-family: arial;font-size: 60px">BIENVENIDO</center>
		 			 </h1>
			 </td>
		 
		 	<td width="10%"  style="border:none">
		 
		 
			 </td>
		 
		 
		</tr>

				<tr>
		 
		 	<td colspan="3" style="margin:20px; height: 200px; " >

		 			 <table style="margin:10px; width: 80%; margin: auto; margin-bottom:20px;">
		 			    <tr>
		 			    	<td  style="color:#858580; font-weight: bold; text-align:center"> 
		 			    	    <!-- EN "NOMBRE" va el name de quien envia el menssaje -->
		 			    	    <!--Nos falto lo del asunto -->
		 			    		<p>Hola ${nombre}! Gracias por Registrarte en Sascha, ahora necesitas descargar nuestra aplicacion movil para solicitar una cita con nuestro calificado grupo de nutricionistas.</p>
		 			    		<p>Nombre de Usuario: ${nombre_usuario}</p>
		 			    		<p>Correo: <a style="text-decoration:none;" href="">${correo}</a></p>
		 			    		<p>Contraseña: ${contraseña}</p>
		 			    		<h3 style="color:#3da3cb; font-family:arial">DESCARGAR</h3>
		 			    		 <!-- enlace de descarga -->
                                <center><a style="background:#3da3cb; padding: 10px; min-width: 100px; border-radius: 5px; color:#fff; font-weight: bold; font-family: arial; text-decoration: none;" href="">Play Store</a>
                                
                                <a style="background:#3da3cb; padding: 10px; min-width: 100px; border-radius: 5px; color:#fff; font-weight: bold; font-family: arial; text-decoration: none;" href="">AppStore</a></center>
		 			    	</td>
		 			    </tr>

		 			 	
		 			 </table>
		 
			 </td>
		 
		</tr>

		<tr style="border:none">
		 

			 <td style="border-top:1px solid gray; background: -prefix-linear-gradient(#1c6b34, #7ab740);

background: linear-gradient(#1c6b34, #7ab740);" colspan="3" >
		             
		 			<p style="text-align:center; color:white">
		 				<a style="text-decoration:none; color:#FFFFFF;">www.saschanutric.com</a> | twitter: @saschanutric
		 			</p>
		 			<p style="text-align:center; color:white">Tel: 0251-7272468</p>
		 			<p style="text-align:center; color:white">Direccion: Barquisimeto, Edo. Lara</p>
			 </td>
		 

		 
		 
		</tr>
		 
	 </table>
 
</body>
</html>
	`
}

module.exports = correoTemplate