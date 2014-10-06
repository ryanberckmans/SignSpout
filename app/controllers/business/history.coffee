`import Ember from 'ember'`

BusinessHistoryController = Ember.Controller.extend # Note, this is Controller and not ObjectController because business.history has no model
  needs: 'business'

`export default BusinessHistoryController`
