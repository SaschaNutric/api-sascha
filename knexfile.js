
module.exports = {
	development: {
   		client: "postgresql",
		connection: {
			host: "localhost",
			user: "postgres",
			password: "1234",
			database: "saschadb"
		}
	},

	production: {
   		client: "postgresql",
		connection: {
			host: "ec2-54-243-210-70.compute-1.amazonaws.com",
			user: "byqkxhkjgnspco",
			password: "7f90354e72f531d4d0deb47be4fdfb68765244e8a5d97ca9c9f7f97c05a0a9a9",
			database: "d7h3pnfqclegkn"
		}
	}
}
/*
if (process.env.NODE_ENV === 'development') {
	console.log("MODO DEVELOPMENT");
	module.exports = {
   		client: "postgresql",
		connection: {
			host: "localhost",
			user: "postgres",
			password: "1234",
			database: "saschadb"
		}
	}
} else if (process.env.NODE_ENV === 'production') {
	console.log("MODO PRODUCTION");
	module.exports = {
   		client: "postgresql",
		connection: {
			host: "ec2-54-243-210-70.compute-1.amazonaws.com",
			user: "byqkxhkjgnspco",
			password: "7f90354e72f531d4d0deb47be4fdfb68765244e8a5d97ca9c9f7f97c05a0a9a9",
			database: "d7h3pnfqclegkn"
		}
	}
}

*/