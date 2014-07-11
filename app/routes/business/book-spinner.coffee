`import Ember from 'ember'`

route = Ember.Route.extend  
  model: ->
    business = this.modelFor 'business'
    this.store.createRecord 'spinner-shift', { business: business, date: new Date() }    

`export default route`
