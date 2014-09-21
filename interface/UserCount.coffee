module.exports.UserCount = React.createClass
  getInitialState: ->
    return {count: 0}

  componentWillMount: ->
    socket = io '/landing'
    socket.on 'user_count', (data={}) =>
      {count} = data
      @setState {count: count}

  render: ->
    (
      <div>Presentations synced: {@state.count}</div>
    )
