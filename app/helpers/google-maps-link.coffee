`import Ember from 'ember'`

# returns {html} html String containing a google maps link for the passed addressString
googleMapsLink = (addressString) ->
  new Ember.Handlebars.SafeString " (<a href='https://maps.google.com/maps?q=" + encodeURIComponent(addressString) + "' target='_blank'>map</a>)"

GoogleMapsLinkHelper = Ember.Handlebars.makeBoundHelper googleMapsLink

`export default GoogleMapsLinkHelper`
