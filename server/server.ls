require! './bootstrap'

socket-redis  = require \socket.io-redis
socket-router = require \./utils/socket-router
Hapi          = require \hapi
server        = new Hapi.Server!
server.connection do
  port: 5555

io = require(\socket.io)(server.listener)
# SocketIO is connected through
# Redis, so many instances can be launched
io.adapter do
  socket-redis do
    host: \redis
    port: 6379

io.on 'connection', socket-router.listen

server.start!

module.exports = do
  server: server
  io: io

module.exports <<< bootstrap

console.log 'the server is up!'
