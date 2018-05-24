'use strict'

const Bookshelf      = require('../commons/bookshelf');
const TipoIncidencia = require('./tipo_incidencia');
const Motivo         = require('./motivo');

let Incidencia = Bookshelf.Model.extend({
  tableName: 'incidencia',
  idAttribute: 'id_incidencia',
  tipoIncidencia: function () {
    return this.belongsTo(TipoIncidencia, 'id_tipo_incidencia')
    			.query({ where: { 'tipo_incidencia.estatus': 1 } });
  },
  motivo: function() {
    return this.belongsTo(Motivo, 'id_motivo')
    			.query({ where: { 'motivo.estatus': 1 } });
  }
});

module.exports = Bookshelf.model('Incidencia', Incidencia);
