{PresentationId} = require './PresentationId'

module.exports.SessionCreator = React.createClass
  getInitialState: ->
    return {validated: true}

  pushPass: ->
    pass = @refs.password.getDOMNode().value
    if pass.length < 4
      return @setState {validated: false}
    else
      Q.xhr.post('/setpass', {pass: pass}).then (resp) =>
        @refs.password.getDOMNode().value = ''
        @setState {presentationId: JSON.parse(resp.data).id}

  keyInInput: (e) ->
    if e.which == 13
      @pushPass()

  componentDidMount: ->
    password = @refs.password.getDOMNode()
    password.focus()
    password.addEventListener 'keyup', @keyInInput

  render: ->
    presentationId = ''
    passClasses = []

    if @state.presentationId
      presentationId = <PresentationId key={@state.presentationId} />

    if not @state.validated
      passClasses.push 'invalid'

    (
      <div>
        <input className={passClasses.join(' ')}
               type='password'
               ref='password'
               placeholder='Master Password'
               />

        <button type='button' onClick={@pushPass} className='btn btn-primary'>
          Get the id!
        </button>
        {presentationId}
      </div>
    )
