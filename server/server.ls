require! './bootstrap'
require! \express
require! \body-parser

app    = express!
server = require \http .Server app
io     = require(\socket.io)(server)
socket-redis = require \socket.io-redis

# SocketIO is connected through
# Redis, so many instances can be launched
io.adapter do
  socket-redis do
    host: 'redis'
    port: 6379

# Bind the JSON body parser and static
# files directories
app.use body-parser.json!
app.use do
  '/components'
  express.static \components
app.use do
  '/static'
  express.static \static

server.listen 55555


module.exports = do
  server: server
  io: io

module.exports <<< bootstrap
