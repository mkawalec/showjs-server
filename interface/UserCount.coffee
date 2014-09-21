module.exports.UserCount = React.createClass
  getInitialState: ->
    return {registered: 0, online: 0}

  componentDidMount: ->
    socket = io '/landing'
    socket.on 'user_count', (data={}) =>
      @setState data

  render: ->
    (
      <div>
        <div>Presentations synced: {@state.registered}</div>
        <div>Users online: {@state.online}</div>
      </div>
    )
