module.exports.PresentationId = React.createClass
  render: ->
    (
      <div className='presentation-id'>
        <div>Your presentation id is:</div>
        <div>{@props.key}</div>

        <div>Add this to the head of your site:</div>
        <pre>
          &lt;link rel='stylesheet' src='//client.showjs.io/style.css'&gt;
          &lt;script src='//client.showjs.io/show.js'&gt;&lt;/script&gt;
          &lt;script&gt;ShowJS('{@props.key}');&lt;/script&gt;
        </pre>
      </div>
    )
