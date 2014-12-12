{ bookshelf } = require '../server'


var Step = bookshelf.Model.extend do
  do
    tableName: \steps

  do
    getStep: (id) ->
      Step.forge!
        .query do
          where: { id : id }
        .fetch do
          require: true

module.exports = do
  Model: Step
