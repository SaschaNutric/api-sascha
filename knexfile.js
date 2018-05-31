const DB_HOST    = process.env.DB_HOST    || 'localhost';
const DB_NAME    = process.env.DB_NAME    || 'saschadb';
const DB_USER    = process.env.DB_USER    || 'postgres';
const DB_PASS    = process.env.DB_PASS    || '1234';
const DB_CHARSET = process.env.DB_CHARSET || 'utf-8';
const DB_CLIENT  = process.env.DB_CLIENT  || 'postgresql';

module.exports = {
	development: {
   		client: "postgresql",
		connection: {
			host:     "localhost",
			user:     "postgres",
			password: "karem",
			database: "saschadb",
			charset:  "utf-8"
		},
		pool: { min: 10, max: 50 }		
	},

	production: {
   		client: DB_CLIENT,
		connection: {
			host:     DB_HOST,
			user:     DB_USER,
			password: DB_PASS,
			database: DB_NAME,
			charset:  DB_CHARSET
		},
		pool: { min: 10, max: 50 }
	}
}