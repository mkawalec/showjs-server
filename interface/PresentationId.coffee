module.exports.PresentationId = React.createClass
  render: ->
    (
      <div className='presentation-id'>
        <div>Your presentation id is:</div>
          <div>{@props.key}</div>
        </div>
      </div>
    )
