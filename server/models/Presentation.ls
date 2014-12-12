{ bookshelf } = require '../server'
Step = require(\./Step).Model


Presentation = bookshelf.Model.extend do
  do
    tableName: \presentations
    getLastStep: ->
      Step.forge!
        .query (q) ->
          q.where(\presentation_id, @get('id'))
          q.orderBy \created_at, \desc
          q.limit 1
        .fetch do
          require: true
        .spread (step) -> step

  do
    getPresentation: (id) ->
      Presentation.forge!
        .query do
          where: { id : id }
        .fetch do
          require: true


module.exports = do
  Model: Presentation
