'use strict'

const Bookshelf = require('../commons/bookshelf');
const Unidad = require('./unidad');
const Alimento = require('./alimento')

let Grupo_alimenticio = Bookshelf.Model.extend({
  tableName: 'grupo_alimenticio',
  idAttribute: 'id_grupo_alimenticio',
  unidad: function() {
    return this.belongsTo(Unidad, 'id_unidad');
  },
  alimentos: function() {
  	return this.hasMany('Alimento', 'id_grupo_alimenticio');
  }
});

module.exports = Bookshelf.model('Grupo_alimenticio', Grupo_alimenticio);
