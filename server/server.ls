require! './bootstrap'

Hapi         = require \hapi
server       = Hapi.create-server 55555
io           = require(\socket.io)(server.listener)
socket-redis = require \socket.io-redis

# SocketIO is connected through
# Redis, so many instances can be launched
io.adapter do
  socket-redis do
    host: \redis
    port: 6379


socket-router = require \./utils/socket-router
io.on 'connection', socket-router


module.exports = do
  server: server
  io: io

console.log 'the server is up!'
module.exports <<< bootstrap
