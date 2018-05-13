'use strict'

const Bookshelf = require('../commons/bookshelf');
const GrupoAlimenticio = require('./grupo_alimenticio');

let Comida = Bookshelf.Model.extend({
  tableName: 'comida',
  idAttribute: 'id_comida',
  gruposAlimenticios: function () {
    return this.belongsToMany(GrupoAlimenticio, 'detalle_plan_dieta', 'id_comida', 'id_grupo_alimenticio');
  }
});

module.exports = Bookshelf.model('Comida', Comida);
