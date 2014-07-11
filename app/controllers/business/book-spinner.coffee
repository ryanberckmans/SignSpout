`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  needs: 'business'

  actions:
    saveSpinnerShift: ->
      business = this.get 'controllers.business.model'

      # this.model is a newly-instantiated, unsaved SpinnerShift. The Business is associated with the SpinnerShift at the time of instantiation. See routes/business/book-spinner.
      newSpinnerShift = this.get 'model'
      newSpinnerShift.save()

      # Warning, when using belongsTo:hasMany, the belongsTo side must be set BEFORE the hasMany side.
      # Ie, SpinnerShift.belongsTo Business must be set BEFORE Business.hasMany SpinnerShift.
      business.addSpinnerShift newSpinnerShift

      this.transitionToRoute 'business'
      null

`export default controller`
