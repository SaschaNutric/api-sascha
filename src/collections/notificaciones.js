'use strict'

const Bookshelf = require('../commons/bookshelf');
const Notificacion = require('../models/notificacion');

const Notificaciones = Bookshelf.Collection.extend({
    model: Notificacion
});

module.exports = Notificaciones;