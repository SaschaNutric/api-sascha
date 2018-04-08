exports.config = function() {
	const envJSON  = require('./env.variables.json');
	const node_env = process.env.NODE_ENV || 'development';
	return envJSON[node_env];
}