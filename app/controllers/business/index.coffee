`import Ember from 'ember'`

BusinessIndexController = Ember.ObjectController.extend
  needs: 'business'

  isDemoButton: (->
    @get('controllers.business.id') == 'demo'
  ).property('controllers.business.id')

`export default BusinessIndexController`
