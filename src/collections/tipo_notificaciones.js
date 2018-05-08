'use strict'

const Bookshelf        = require('../commons/bookshelf');
const TipoNotificacion = require('../models/tipo_notificacion');

const TipoNotificaciones = Bookshelf.Collection.extend({
    model: TipoMoTipoNotificaciontivo
});

module.exports = TipoNotificaciones;