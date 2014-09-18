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


io.on 'connection', (socket) ->
  socket.on 'slide_change', (data) ->
    {doc_id, pass, slide} = data
    if not doc_id?
      return socket.emit 'error', {msg: 'Missing document id'}

    Master.findOne {doc_id: doc_id}, 'password', (err, master) ->
      if err?
        return socket.emit 'error', {msg: 'Mongo error: ' + err}
      if not master?
        return socket.emit 'error', {msg: 'Wrong doc_id'}

      if get_hash(pass) == master.password
        redis_client.set redis_prefix + doc_id, JSON.stringify(slide), ->
          io.of("/#{doc_id}").emit 'sync', {slide: slide}
      else
        socket.emit 'error', {msg: 'Wrong password'}

  socket.on 'check_pass', (data) ->
    {doc_id, pass} = data

    Master.findOne {doc_id: doc_id}, 'password', (err, master) ->
      if err?
        return socket.emit 'error', {msg: 'Mongo error: ' + err}
      if not master?
        return socket.emit 'error', {msg: 'Wrong doc_id'}

      if get_hash(pass) == master.password
        return socket.emit {valid: true}
      else
        return socket.emit {valid: false}

  socket.on 'sync_me', (sync_params) ->
    {doc_id} = sync_params
    if not doc?
      socket.emit 'error', {msg: 'Missing doc id'}
    else
      redis_client.get redis_prefix + doc_id, (data) ->
        if data?
          socket.emit 'sync', JSON.parse(data)
        else
          socket.emit 'sync', default_slide


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


