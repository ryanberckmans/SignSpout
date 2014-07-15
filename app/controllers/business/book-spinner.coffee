`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  needs: 'business'

  actions:
    setSpinnerShiftDate: (newSpinnerShiftMoment) ->
      this.get('model').set 'date', newSpinnerShiftMoment.toDate()
      null

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

  # earliestShiftStartAsMoment is the earliest time of day, on the currently selected day, that a shift may start
  earliestShiftStartAsMoment: (->
    moment(@get 'date').hour(7).startOf 'hour' # ie, 7am is the earliest start
  ).property('date')

  soonestBookingDateAsMoment: moment().add('days', 1) # ie tomorrow is the soonest you can book a shift
  latestBookingDateAsMoment: moment().add('days', 8) # ie a week from tomorrow is the soonest you can book a shift

`export default controller`
