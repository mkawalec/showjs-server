redis   = require 'redis'
Emitter = require 'node-redis-events'

# Events can be sent between instances,
# so that all the clients would get notified
emitter = new Emitter do
  namespace: \syncjs

redis-client = redis.create-client 6379, 'redis'
redis-prefix = \showjs.

module.exports = do
  redis-client: redis-client
  redis-prefix: redis-prefix
  emitter: emitter

