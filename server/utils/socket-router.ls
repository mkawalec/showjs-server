{ obj-to-pairs, each, curry } = require 'prelude-ls'
Joi = require 'joi'


registered-handlers = {}

handle-req = (handler, socket, data) -->
  if handler.validate?
    { err } = Joi.validate(data, handler.validate)
    if err
      return socket.emit 'validation_error', err

  handler.handler socket,data


SocketRouter = (socket) ->
  obj-to-pairs registered-handlers
    |> each (event, handler) ->
      socket.on event, (handle-req handler, socket)


SocketRouter::register = (event, handler) ->
  registered-handers[event] = handler

module.exports = new SocketRouter
