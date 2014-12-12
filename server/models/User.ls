{ bookshelf } = require '../server'
Promise       = require \bluebird
crypto        = Promise.promisifyAll require(\crypto)

Presentation = require \./Presentation


User = bookshelf.Model.extend do
  do
    tableName: \users
    set: (params) ->
      if params.password?
        crypto.pseudoRandomBytes 128.then (buf) ->
          params.salt = buf.toString!

          sha = crypto.createHash \sha256
          sha.update(params.salt + params.password);
          params.password = sha.digest \base64

          bookshelf.Model.prototype.set.call(@, params);

      else
        bookshelf.Model.prototype.set.apply(@, arguments);

    checkPass: (pass) ->
      return new Promise (resolve) ->
        salt = @get \salt
        db-pass = @get \password

        sha = crypto.createHash \sha256
        sha.update(salt + params.pass);

        if db-pass === sha.digets \base64
          resolve @
        else
          throw new Error 'The passwords don\'t match'

    presentations: ->
      @hasMany Presentation.Model

  do
    getUser: (id) ->
      User.forge!
        .query do
          where: { id : id }
        .fetch do
          require: true
          withRelated: do
            \presentations

module.exports = do
  Model: User
