`import Ember from 'ember'`

# @param {String, String} return a google map link for the passed businessName and businessAddress
# @return {html} html String containing a google maps link for the passed businesName and businesAddress
#
# Warning: use 
#              {{#with something.business}}
#                {{google-maps-link name address}}
#              {{/with}} 
#
#          so that the something.business Promise is settled before invoking this helper. 
#          Helpers do not work with promises.
googleMapsLink = (businessName, businessAddress) ->
  businessNameAndAddress = (businessName + ", " + businessAddress).replace(/'/g, "%27") # single quote isn't encoded by encodeURIComponent
  new Ember.Handlebars.SafeString " (<a href='https://maps.google.com/maps?q=" + encodeURIComponent(businessNameAndAddress) + "' target='_blank'>map</a>)"

GoogleMapsLinkHelper = Ember.Handlebars.makeBoundHelper googleMapsLink

`export default GoogleMapsLinkHelper`
