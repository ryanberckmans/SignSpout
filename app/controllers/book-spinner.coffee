`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  actions:
    createSpinnerShift: ->
      business = this.get 'model'
      newSpinnerShift = this.store.createRecord 'spinner-shift', { business: business, date: new Date() }
      newSpinnerShift.save()

      # I can use newSpinnerShift immediately, because the model is instantiated locally and given an id by emberfire adapter. Suppose so, anyway :0
      business.addSpinnerShift newSpinnerShift

      this.transitionToRoute 'business', business
      null

`export default controller`
