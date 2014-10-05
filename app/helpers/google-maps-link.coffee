`import Ember from 'ember'`

# returns {html} html String containing a google maps link for the passed Business model
googleMapsLink = (business) ->
  new Ember.Handlebars.SafeString " (<a href='https://maps.google.com/maps?q=" + encodeURIComponent(business.get('name') + ", " + business.get('address')) + "' target='_blank'>map</a>)"

GoogleMapsLinkHelper = Ember.Handlebars.makeBoundHelper googleMapsLink

`export default GoogleMapsLinkHelper`
