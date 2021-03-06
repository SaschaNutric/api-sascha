'use strict'

const Bookshelf = require('../commons/bookshelf');
const Parametro = require('./parametro');
const Servicio = require('./servicio');

let Parametro_servicio = Bookshelf.Model.extend({
  tableName: 'parametro_servicio',
  idAttribute: 'id_parametro_servicio',
  parametro: function () {
    return this.belongsTo(Parametro, 'id_parametro')
    			.query({ where: { 'parametro.estatus': 1 } });
  },
  servicios: function() {
    return this.hasMany(Servicio, 'id_servicio')
          .query({ where: { 'servicio.estatus': 1 } });
  },
});

module.exports = Bookshelf.model('Parametro_servicio', Parametro_servicio);
