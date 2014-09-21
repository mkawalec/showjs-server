{SessionCreator} = require './SessionCreator'
{UserCount}      = require './UserCount'

React.renderComponent(
  <SessionCreator />
  document.getElementById('session-creator')
)


React.renderComponent(
  <UserCount />
  document.getElementById('user-count')
)

