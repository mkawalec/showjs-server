#!/usr/bin/env coffee

bodyParser = require 'body-parser'
express    = require 'express'
app        = express()
server     = require('http').Server(app)
io         = require('socket.io')(server)
_          = require 'lodash'
crypto     = require 'crypto'

# Redis init
redis = require 'redis'
redis_client = redis.createClient()
redis_prefix = 'showjs.'

# Redis Adapter for socket.io
socket_redis = require 'socket.io-redis'
io.adapter(socket_redis({host: 'localhost', port: 6379}))

# Mongodb init
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/showjs'
Master = mongoose.model 'Master', {doc_id: String, password: String}

app.use(bodyParser.json())
app.use('/components', express.static('components'))
app.use('/static', express.static('static'))
server.listen(55555)

default_slide = {indexh: 0, indexv: 0}

get_hash = (password) ->
  hasher        = crypto.createHash 'sha256'
  password_hash = hasher.update password, 'utf-8'
  return hasher.digest 'base64'

send_stats = (room_id) ->
  clients = _.keys(io.sockets.adapter.rooms[room_id]).length
  total_clients = io.sockets.sockets.length

  io.to(room_id).emit 'stats',
    {this_document: clients, total: total_clients}

validateProducer = (socket, reqs=[]) ->
  # A decorator validating a form of a request
  (fn) ->
    ->
      args = arguments

      if Object.prototype.toString.call(args[0]) != '[object Object]'
        socket.emit 'error_msg',
          {msg: 'Wrong type of an arguments (needs object)'}
      else if _.every(reqs, (req) ->
        if not args[0][req]?
          socket.emit 'error_msg', {msg: 'Missing ' + req}
          false
        else
          true
      )
        fn.apply this, arguments


io.on 'connection', (socket) ->
  room_id = undefined
  validate = _.partial validateProducer, socket

  socket.on 'disconnect', ->
    # If the preson disconnects, notify everyone in their room
    if room_id then send_stats(room_id)

  socket.on 'join_room', validate(['doc_id']) (data) ->
    {doc_id} = data
    room_id = doc_id

    socket.join doc_id
    redis_client.get redis_prefix + doc_id, (data) ->
      if data?
        socket.emit 'sync', JSON.parse(data)
      else
        socket.emit 'sync', {slide: default_slide, setter: -1}

    send_stats(doc_id)

  socket.on 'slide_change', validate(['doc_id', 'pass', 'slide', 'setter']) (data) ->
    {doc_id, pass, slide, setter} = data

    Master.findOne {doc_id: doc_id}, 'password', (err, master) ->
      if err?
        return socket.emit 'error_msg', {msg: 'Mongo error: ' + err}
      if not master?
        return socket.emit 'error_msg', {msg: 'Wrong doc_id'}

      if get_hash(pass) == master.password
        payload =
          slide: slide
          setter: setter

        redis_client.set redis_prefix + doc_id, JSON.stringify(payload), ->
          io.to(doc_id).emit 'sync', payload
      else
        socket.emit 'error_msg', {msg: 'Wrong password'}

  socket.on 'check_pass', validate(['doc_id', 'pass']) (data, cb) ->
    {doc_id, pass} = data

    Master.findOne {doc_id: doc_id}, 'password', (err, master) ->
      if err?
        return socket.emit 'error_msg', {msg: 'Mongo error: ' + err}
      if not master?
        return socket.emit 'error_msg', {msg: 'Wrong doc_id'}

      if get_hash(pass) == master.password
        cb {valid: true}
      else
        cb {valid: false}

  socket.on 'error', ( -> )

chars = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890'

get_id = (length=12) ->
  return _.reduce _.range(length), ((acc) ->
    acc += chars[_.random(0, chars.length-1)]
  ), ''


app.get '/', (req, res) ->
  res.sendFile __dirname + '/index.html'

app.post '/setpass', (req, res) ->
  id     = get_id()
  {pass} = req.body

  current_master = new Master {doc_id: id, password: get_hash(pass)}
  current_master.save (err) ->
    if err?
      res.status(500).send 'Error saving'
    else
      res.send JSON.stringify({id: id})


