'use strict'

const Bookshelf = require('../commons/bookshelf');
const Unidad = require('./unidad');
require('./alimento')

let Grupo_alimenticio = Bookshelf.Model.extend({
  tableName: 'grupo_alimenticio',
  idAttribute: 'id_grupo_alimenticio',
  unidad: function() {
    return this.belongsTo(Unidad, 'id_unidad')
    .query({ where: { 'unidad.estatus': 1 } });
  },
  alimentos: function() {
  	return this.hasMany('Alimento', 'id_grupo_alimenticio')
    .query({ where: { 'alimento.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Grupo_alimenticio', Grupo_alimenticio);
