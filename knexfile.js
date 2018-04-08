const DB_HOST    = process.env.DB_HOST    || 'localhost';
const DB_NAME    = process.env.DB_NAME    || 'saschadb';
const DB_USER    = process.env.DB_USER    || 'postgres';
const DB_PASS    = process.env.DB_PASS    || 'postgres';
const DB_CHARSET = process.env.DB_CHARSET || 'utf-8';
const DB_CLIENT  = process.env.DB_CLIENT  || 'postgresql';

module.exports = {
	development: {
   		client: "postgresql",
		connection: {
			host:     "localhost",
			user:     "postgres",
			password: "postgres",
			database: "saschadb",
			charset:  "utf-8"
		}
	},

	production: {
   		client: DB_CLIENT,
		connection: {
			host:     DB_HOST,
			user:     DB_USER,
			password: DB_PASS,
			database: DB_NAME,
			charset:  DB_CHARSET
		}
	}
}

/*
	host: "ec2-54-243-210-70.compute-1.amazonaws.com",
	user: "byqkxhkjgnspco",
	password: "7f90354e72f531d4d0deb47be4fdfb68765244e8a5d97ca9c9f7f97c05a0a9a9",
	database: "d7h3pnfqclegkn"
*/