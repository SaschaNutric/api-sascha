var express = require('express');
var bodyParser = require('body-parser');
var logger = require('morgan');
var methodOverride = require('method-override')
var cors = require('cors');
var routes = require('./src/routes'); 
var app = express();
app.use(cors({
    origin: '*',
    withCredentials: false,
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin' ]
}));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(methodOverride());
app.use('/', routes);
module.exports = app;
