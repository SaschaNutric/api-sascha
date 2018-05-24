'use strict'

const Bookshelf = require('../commons/bookshelf');
 require('./grupo_alimenticio');

let Alimento = Bookshelf.Model.extend({
  tableName: 'alimento',
  idAttribute: 'id_alimento',
  grupo_alimenticio: function() {
    return this.belongsTo('Grupo_alimenticio', 'id_grupo_alimenticio')
    			.query({ where: { 'grupo_alimenticio.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Alimento', Alimento);
