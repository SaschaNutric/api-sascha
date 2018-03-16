"use strict";

var Schema = {
	users: {
		id: {type: "increments", nullable: false, primary: true},
		email: {type: "string", maxlength: 254, nullable: false, unique: true},
		name: {type: "string", maxlength: 150, nullable: false},
		password: {type: "string", nullable: false}
	},
	perfil: {
		id: {type: "increments", nullable: false, primary: true},
		user_id: {type: "integer", nullable: false, unsigned: true,references:"users.id"},
		pelo: {type: "integer", nullable: false, unsigned: true},
		piel: {type: "string", maxlength: 150, nullable: false},
		algomas: {type: "string", maxlength: 150, nullable: false}
	},
};

module.exports = Schema;