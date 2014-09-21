module.exports.PresentationId = React.createClass
  render: ->
    (
      <div className='presentation-id'>
        <div>Your presentation id is:</div>
        <div>{@props.key}</div>

        <div>Add this to the head of your site:</div>
        <pre>
          &lt;link rel='stylesheet' src='//showjs.io/frontend/style.css'&gt;
          &lt;script src='//showjs.io/frontend/show.js'&gt;&lt;/script&gt;
          &lt;script&gt;ShowJS('{@props.key}');&lt;/script&gt;
        </pre>
      </div>
    )
