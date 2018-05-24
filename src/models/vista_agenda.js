'use strict'

const Bookshelf         = require('../commons/bookshelf');
const Servicio          = require('./servicio');
const ParametroCliente  = require('./parametro_cliente');
const ParametroMeta     = require('./parametro_meta');
const RegimenDieta      = require('./regimen_dieta');
const RegimenSuplemento = require('./regimen_suplemento');
const RegimenEjercicio  = require('./regimen_ejercicio');

let VistaAgenda = Bookshelf.Model.extend({
    tableName: 'vista_agenda',
    idAttribute: 'id_agenda',
    servicio: function() {
        return this.belongsTo(Servicio, 'id_servicio')
                .query({ where: { 'servicio.estatus': 1 } });
    },
    perfil: function () {
        return this.hasMany(ParametroCliente, 'id_cliente', 'id_cliente')
                .query({ where: { 'parametro_cliente.estatus': 1 } });
    },
    regimen_dieta: function() {
        return this.hasMany(RegimenDieta, 'id_cliente', 'id_cliente')
                    .query({ where: { 'regimen_dieta.estatus': 1 } });    
    },
    regimen_suplemento: function () {
        return this.hasMany(RegimenSuplemento, 'id_cliente', 'id_cliente')
            .query({ where: { 'regimen_suplemento.estatus': 1 } });
    },
    regimen_ejercicio: function () {
        return this.hasMany(RegimenEjercicio, 'id_cliente', 'id_cliente')
            .query({ where: { 'regimen_ejercicio.estatus': 1 } });
    },
    metas: function() {
        return this.hasMany(ParametroMeta, 'id_orden_servicio', 'id_orden_servicio')
            .query({ where: { 'parametro_meta.estatus': 1 } });
    }
});

module.exports = Bookshelf.model('VistaAgenda', VistaAgenda);