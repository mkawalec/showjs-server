module.exports.PresentationId = React.createClass
  render: ->
    (
      <div className='presentation-id'>
        <div>Your presentation id is:</div>
        <div>{@props.key}</div>

        <div>Enter this at the end of the body of your site:</div>
        <pre>
          &lt;script type='text/javascript' src='//showjs.io/show.js'&gt;&lt;/script&gt;
          &lt;script type='text/javascript'&gt;Showjs.setDoc('{@props.key}')&lt;/script&gt;
        </pre>
      </div>
    )
