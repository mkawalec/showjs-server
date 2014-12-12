{ bookshelf } = require '../server'


Note = bookshelf.Model.extend do
  do
    tableName: \notes
    set: (params) ->
      params.updated_at = new Date!
      bookshelf.Model.prototype.call this, params

  do
    getStep: (id) ->
      Note.forge!
        .query do
          where: { id : id }
        .fetch do
          require: true

module.exports = do
  Model: Node
