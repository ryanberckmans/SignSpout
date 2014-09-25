`import Ember from 'ember'`

route = Ember.Route.extend  
  model: ->
    spinner = this.modelFor 'spinner'
    store = this.store
    return store.find('spinner-shift').then ->
      return store.filter 'spinner-shift', (spinnerShift) ->
        return spinnerShift.get('spinner') == null

`export default route`
