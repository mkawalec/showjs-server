// Update with your config settings.

module.exports = {

  development: {
    client: 'pg',
    connection: {
      database: process.env.POSTGRES_DATABASE,
      user:     process.env.POSTGRES_USER,
      password: process.env.POSTGRES_PASSWORD,
      host: 'postgres'
    },
    pool: {
      min: 2,
      max: 10
    },
    migrations: {
      tableName: 'knex_migrations'
    }
  },
};
