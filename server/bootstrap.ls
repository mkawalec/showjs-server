redis   = require 'redis'
Emitter = require 'node-redis-events'

# Events can be sent between instances,
# so that all the clients would get notified
emitter = new Emitter do
  namespace: \syncjs
  hostname: \redis

redis-client = redis.create-client 6379, 'redis'
redis-prefix = \showjs.

knex = require \knex do
  client: \pg
  connection: do
    user: process.env.POSTGRES_USER
    password: process.env.POSTGRES_PASSWORD
    database: process.env.POSTGRES_DATABASE
    host: \postgres

bookshelf = require \bookshelf do
  knex

module.exports = do
  redis-client: redis-client
  redis-prefix: redis-prefix
  emitter: emitter
  knex: knex
  bookshelf: bookshelf

