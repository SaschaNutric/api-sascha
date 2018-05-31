var express = require('express')
    bodyParser = require('body-parser')
    multer = require('multer')
    logger = require('morgan')
    routes = require('./src/routes')
    app = express();

app.set('secret', 'SECRET');

app.use(function(req, res, next) {
  res.header('Access-Control-Allow-Origin', "*");
  res.header('Access-Control-Allow-Methods','GET,PUT,POST,DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next();
});
app.use(logger('dev'));
app.use(multer({ dest: "./imagenes" }))
app.use(bodyParser.json());
app.use('/', routes);

app.use(function(req, res, next) {
  let err = new Error('No encontrado');
  err.status = 404;
  next(err);
});

app.use(function(err, req, res, next) {
  res.status(err.status || 500).json({ error: true, mensaje: err.message || 'Fallo del servidor' });
});

const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || 'localhost';

app.listen(PORT, function() {
  console.log(`Servidor express corriendo en http://${HOST}:${PORT}`)
});

module.exports = app;
