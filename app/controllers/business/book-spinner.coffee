`import Ember from 'ember'`

controller = Ember.ObjectController.extend
  needs: 'business'

  actions:
    setSpinnerShiftDate: (newSpinnerShiftDateAsMoment) ->
      @set 'selectedDateAsMoment', newSpinnerShiftDateAsMoment
      startDateAndTime = moment(@get('model').get 'startDateAndTime')
      startDateAndTime.date(newSpinnerShiftDateAsMoment.date());
      @get('model').set 'startDateAndTime', startDateAndTime.toDate()
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

  ##############################
  # Static Properties

  earliestShiftStartTimeOfDayAsMoment: moment().hour(7).startOf 'hour' # ie, 7am is the earliest shift start time of day
  
  latestShiftEndTimeOfDayAsMoment: moment().hour(19).startOf 'hour' # ie, 7pm is the latest shift end time of day
  
  shiftMinimumDurationInMinutes: 120
  
  latestShiftStartTimeOfDayAsMoment: (->
    @get('latestShiftEndTimeOfDayAsMoment').subtract 'minutes', @get('shiftMinimumDurationInMinutes')
  ).property 'latestShiftEndTimeOfDayAsMoment', 'shiftMinimumDurationInMinutes'
  
  # Instead of allowing the user to type in a shift start time of day, or select an arbitrary start time, only permit a set of start times, such as shifts starting on the half hour
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

  shiftStartTimesOfDayStrings: (->
    shiftStartTimesOfDayStrings = []
    shiftStartTimesOfDayStrings.push s.format('h:mma') for s in @get 'shiftStartTimesOfDayAsMoments'
    shiftStartTimesOfDayStrings
  ).property 'shiftStartTimesOfDayAsMoments'

  ##############################
  # Properties based on the time now. TBD - what happens if the user leaves the page open past midnight and then books a shift? Then they would be able to book a shift with less than 24 hours notice.

  soonestBookingDateAsMoment: moment().add('days', 1).startOf 'day' # ie tomorrow is the soonest you can book a shift
  latestBookingDateAsMoment: moment().add('days', 8).startOf 'day' # ie a week from tomorrow is the soonest you can book a shift

  ##############################
  # Current User Selections

  selectedDateAsMoment: null #@get 'soonestBookingDateAsMoment' # ie, the default selected day is the soonest booking day
  selectedStartTimeOfDayAsMoment: null #@get 'earliestShiftStartTimeOfDayAsMoment' # ie, the default start time of day is the earliest
  selectedEndTimeOfDayAsMoment: null #@get 'latestShiftEndTimeOfDayAsMoment' # ie, the default end time of day is the latest

  shiftEndTimesOfDayAsMoments: (->
    # TBD - shiftEndTimesOfDayAsMoments populated dynamically, based on selectedStartTimeOfDayAsMoment
    []
  ).property() # TBD depends on currently selected start time, minimum duration and the latest shift end time

`export default controller`
