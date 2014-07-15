`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  needs: 'business'

  actions:
    setSpinnerShiftDate: (newSpinnerShiftMoment) ->
      @get('model').set 'startDateAndTime', newSpinnerShiftMoment.toDate()
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

  # earliest(latest)ShiftStart(End)TimeOfDayAsMoment is the earliest (latest) time of day, on the currently selected day, that a shift may start (finish)
  earliestShiftStartTimeOfDayAsMoment: (->
    moment(@get 'startDateAndTime').hour(7).startOf 'hour' # ie, 7am is the earliest shift start time of day
  ).property 'startDateAndTime'

  latestShiftEndTimeOfDayAsMoment: (->
    moment(@get 'startDateAndTime').hour(19).startOf 'hour' # ie, 7pm is the latest shift end time of day
  ).property 'startDateAndTime'

  shiftMinimumDurationInMinutes: 120

  latestShiftStartTimeOfDayAsMoment: (->
    @get('latestShiftEndTimeOfDayAsMoment').subtract 'minutes', @get('shiftMinimumDurationInMinutes')
    ).property 'latestShiftEndTimeOfDayAsMoment', 'shiftMinimumDurationInMinutes'

  # Instead of allowing the user to type in a shift start time of day, or select any start time, only permit a set of start times, such as allowing shifts to start on the half hour.
  shiftStartTimesOfDayAsMoments: (->
    shiftStartTimesOfDay = []
    latestShiftStartTimeOfDayAsMoment = @get 'latestShiftStartTimeOfDayAsMoment'
    nextShiftStartTime = @get('earliestShiftStartTimeOfDayAsMoment').clone()
    loop
      shiftStartTimesOfDay.push nextShiftStartTime
      nextShiftStartTime = nextShiftStartTime.clone().add 'minutes', 30 # ie allow shift start times in increments of 30 minutes
      break unless nextShiftStartTime.isBefore(latestShiftStartTimeOfDayAsMoment) or nextShiftStartTime.isSame(latestShiftStartTimeOfDayAsMoment, 'minute')
    shiftStartTimesOfDay
  ).property 'earliestShiftStartTimeOfDayAsMoment', 'latestShiftStartTimeOfDayAsMoment'

  shiftEndTimesOfDayAsMoments: (->
    shiftEndTimesOfDay = []
  ).property() # TBD depends on currently selected start time, minimum duration and the latest shift end time

  soonestBookingDateAsMoment: moment().add('days', 1) # ie tomorrow is the soonest you can book a shift
  latestBookingDateAsMoment: moment().add('days', 8) # ie a week from tomorrow is the soonest you can book a shift

`export default controller`
