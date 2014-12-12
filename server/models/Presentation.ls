{ bookshelf } = require '../server'


var Presentation = bookshelf.Model.extend do
  do
    tableName: \presentations

  do
    getPresentation: (id) ->
      Presentation.forge!
        .query do
          where: { id : id }
        .fetch do
          require: true

module.exports = do
  Model: Presentation
