'use strict'

const Bookshelf = require('../commons/bookshelf');
const Servicio = require('./servicio');
const Parametro = require('./parametro');
const DetalleVisita = require('./detalle_visita');


let VistaVisita = Bookshelf.Model.extend({
    tableName: 'vista_visita',
    idAttribute: 'id_visita',
    parametros: function () {
        return this.hasMany(DetalleVisita, 'id_visita')
                    .query({ where: { 'estatus': 1 } });
    }
});

module.exports = Bookshelf.model('VistaVisita', VistaVisita);