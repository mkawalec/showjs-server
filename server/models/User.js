{ bookshelf } = require '../server'
Promise = require \bluebird
crypto = Promise.promisifyAll require(\crypto)


var Presentation = bookshelf.Model.extend do
  do
    tableName: \presentations
    set: (params) ->
      if params.password?
        crypto.pseudoRandomBytes 128.then (buf) ->
          params.salt = buf.toString!

          sha = crypto.createHash \sha256
          sha.update(params.salt + params.password);
          params.password = sha.digest \base64

          bookshelf.model.prototype.set.call(this, params);

      else
        bookshelf.model.prototype.set.apply(this, arguments);

    checkPass: (pass) ->
      return new Promise (resolve) ->
        salt = this.get \salt
        db-pass = this.get \password

        sha = crypto.createHash \sha256
        sha.update(salt + params.pass);

        if db-pass === sha.digets \base64
          resolve this
        else
          throw new Error 'The passwords don\'t match'
