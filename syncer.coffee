#!/usr/bin/env coffee

bodyParser = require 'body-parser'
express    = require 'express'
app        = express()
server     = require('http').Server(app)
io         = require('socket.io')(server)
_          = require 'lodash'
crypto     = require 'crypto'

# Redis init
redis   = require 'redis'
Emitter = require 'node-redis-events'
emitter = new Emitter { namespace: 'syncjs' }
redis_client = redis.createClient()
redis_prefix = 'showjs.'

# Redis Adapter for socket.io
socket_redis = require 'socket.io-redis'
io.adapter(socket_redis({host: 'localhost', port: 6379}))

# Mongodb init
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/showjs'

# Mongoose models
Master = mongoose.model 'Master', {doc_id: String, password: String}
Comment = mongoose.model 'Comment', {
  doc_id: String
  contents: String
  author: String
  in_reply_to: String
}

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

  emitter.emit 'online_count', total_clients

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

send_comments = (socket, doc_id) ->
  # Send comments for a given doc_id

  comments = Comment.find {doc_id: doc_id}, (err, comments) ->
    socket.emit 'comment', comments

io.on 'connection', (socket) ->
  room_id = undefined
  validate = _.partial validateProducer, socket

  socket.on 'disconnect', ->
    # If the preson disconnects, notify everyone in their room
    if room_id then send_stats(room_id)

  socket.on 'add_comment', validate(['doc_id', 'contents', 'author']) (data) ->
    comment = new Comment {
      doc_id: data.doc_id
      contents: data.contents
      author: data.author
      in_reply_to: data.in_reply_to
    }

    comment.save (err) ->
      if not err?
        io.to(doc_id).emit 'comment', comment

  socket.on 'join_room', validate(['doc_id']) (data) ->
    {doc_id} = data
    room_id = doc_id

    socket.join doc_id
    redis_client.get doc_id, (err, data) ->
      if data?
        socket.emit 'sync', JSON.parse(data)
      else
        socket.emit 'sync', {slide: default_slide, setter: -1}

    send_stats(doc_id)
    send_comments(socket, doc_id)

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

        redis_client.set doc_id, JSON.stringify(payload), ->
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
      Master.count (err, count) ->
        emitter.emit 'new_user', count

      res.send JSON.stringify({id: id})


io.of('/landing').on 'connection', (socket) ->
  emitter.on 'new_user', (count) ->
    io.of('/landing').emit 'user_count', {registered: count}

  emitter.on 'online_count', (count) ->
    io.of('/landing').emit 'user_count', {online: count}

  Master.count (err, count) ->
    total_clients = io.sockets.sockets.length
    io.of('/landing').emit 'user_count', {registered: count, online: total_clients}

