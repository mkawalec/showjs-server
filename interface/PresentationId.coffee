module.exports.PresentationId = React.createClass
  render: ->
    (
      <div className='presentation-id'>
        <div>Your presentation id is:</div>
        <div>{@props.key}</div>

        <div>Add this to the end of the body tag of your site:</div>
        <pre>
          &lt;script src='//showjs.io/show.js'&gt;&lt;/script&gt;
          &lt;script&gt;Showjs('{@props.key}');&lt;/script&gt;
        </pre>
      </div>
    )
