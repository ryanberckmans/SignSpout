`import Ember from 'ember'`
`import { SHIFT_CAN_MATCH_DEADLINE_MINUTES } from '../../mixins/spinner-shift-sorter'`

controller = Ember.ObjectController.extend
  needs: 'business'

  shiftCanMatchDeadlineMinutesDisplay: (SHIFT_CAN_MATCH_DEADLINE_MINUTES / 60) + ' hours'

  actions:
    createSpinnerShift: ->
      _this = this

      @set 'bookSpinnerButtonIsDisabled', true

      business = @get 'controllers.business.model'

      newSpinnerShift = @store.createRecord 'spinner-shift', { business: business, startDateAndTime: @get('selectedStartDateAndTimeAsMoment').toDate(), endDateAndTime: @get('selectedEndDateAndTimeAsMoment').toDate() }

      onAssociationSuccess = ->
        Ember.Logger.info 'book-spinner: associated new spinnerShift ' + newSpinnerShift.id + ' with business ' + business.id
        _this.transitionToRoute 'business'

      onAssociationFail = (reason) ->
        # When failing to associate a new SpinnerShift with its Business, we must delete the new SpinnerShift avoid inconsistent state
        Ember.Logger.warn 'book-spinner: failed to associate new spinnerShift ' + newSpinnerShift.id + ' with business ' + business.id + ". deleting this spinnerShift. This error isn't rethrown and is trapped here. Reason: " + reason
        onDestroySuccess = ->
          Ember.Logger.warn 'book-spinner: destroyed unassociated spinnerShift ' + newSpinnerShift.id + '. Transitioning to business route, although no new SpinnerShift was created.'
          _this.transitionToRoute 'business'
        onDestroyFail = (failedToDestroyReason) ->
          Ember.Logger.error 'book-spinner: failed destroy unassociated spinnerShift ' + newSpinnerShift.id + '. This error is intentionally rethrown, which will break the UI right now, because this should not happen.'
          throw failedToDestroyReason
        newSpinnerShift.destroyRecord().then onDestroySuccess, onDestroyFail
      
      onSpinnerShiftSaveSuccess = ->
        Ember.Logger.info 'book-spinner: created new spinnerShift' + newSpinnerShift.id + '. attempting to associate it with business ' + business.id

        # Warning, when using belongsTo:hasMany, the belongsTo side must be set BEFORE the hasMany side.
        # Ie, SpinnerShift.belongsTo Business must be set BEFORE Business.hasMany SpinnerShift.
        business.addSpinnerShift(newSpinnerShift).then onAssociationSuccess, onAssociationFail

      onSpinnerShiftSaveFail = (reason) ->
        Ember.Logger.warn 'book-spinner: failed to create new spinner shift, most likely this user ' + _this.get('auth.uid') + ' isn\'t the owner of business ' + business.id + ". This error isn't rethrown and is trapped here. Reason: " + reason
        newSpinnerShift.rollback() # Since the newSpinnerShift failed to save, it's now transient and inconsistent, and should be deleted from the store. rollback() on a new record causes deletion from the store.
        Ember.Logger.debug 'book-spinner: newSpinnerShift, which failed to save, has been deleted from the local store'
        _this.set 'bookSpinnerButtonIsDisabled', false

      newSpinnerShift.save().then onSpinnerShiftSaveSuccess, onSpinnerShiftSaveFail

      # TODO TODO TODO
      # TODO TODO TODO - when anything fails, need transition to some kind of error page. Or set an error message. Can't just transition back to 'business' silently
      # TODO TODO TODO
      
      null

  ##############################
  # Configurable Properties
  #############################

  earliestShiftStartTimeOfDayAsMoment: moment().hour(7).startOf 'hour' # ie, 7am is the earliest shift start time of day
  
  latestShiftEndTimeOfDayAsMoment: moment().hour(19).startOf 'hour' # ie, 7pm is the latest shift end time of day
  
  shiftMinimumDurationInMinutes: 120
  shiftMaximumDurationInMinutes: 8*60

  shiftTimeIncrementInMinutes: 30 # ie allow shift start / end times in increments of 30 minutes

  defaultShiftEndTimeIndex: 4 # set the shift end time to this default index when the page loads or the start time changes.                              

  #############################
  # Shift start time of day
  #############################
  
  latestShiftStartTimeOfDayAsMoment: (->
    @get('latestShiftEndTimeOfDayAsMoment').clone().subtract 'minutes', @get('shiftMinimumDurationInMinutes')
  ).property 'latestShiftEndTimeOfDayAsMoment', 'shiftMinimumDurationInMinutes'
  
  # Instead of allowing the user to type in a shift start time of day, or select an arbitrary start time, only permit a set of start times, such as shifts starting on the half hour
  shiftStartTimesOfDayAsMoments: (->
    shiftStartTimesOfDayAsMoments = []
    latestShiftStartTimeOfDayAsMoment = @get 'latestShiftStartTimeOfDayAsMoment'
    nextShiftStartTime = @get('earliestShiftStartTimeOfDayAsMoment').clone()
    shiftTimeIncrementInMinutes = @get 'shiftTimeIncrementInMinutes'
    loop
      shiftStartTimesOfDayAsMoments.push nextShiftStartTime
      nextShiftStartTime = nextShiftStartTime.clone().add 'minutes', shiftTimeIncrementInMinutes
      break unless nextShiftStartTime.isBefore(latestShiftStartTimeOfDayAsMoment) or nextShiftStartTime.isSame(latestShiftStartTimeOfDayAsMoment, 'minute')
    shiftStartTimesOfDayAsMoments
  ).property 'earliestShiftStartTimeOfDayAsMoment', 'latestShiftStartTimeOfDayAsMoment', 'shiftTimeIncrementInMinutes'

  shiftStartTimesOfDayAsStrings: (->
    shiftStartTimesOfDayAsStrings = []
    shiftStartTimesOfDayAsStrings.push s.format('h:mma') for s in @get 'shiftStartTimesOfDayAsMoments'
    shiftStartTimesOfDayAsStrings
  ).property 'shiftStartTimesOfDayAsMoments'

  shiftStartTimesOfDayStruct: (-> # contains no new data and only exists to provide a format ingestable by Ember.select
    shiftStartTimesOfDayStruct = []
    shiftStartTimesOfDayAsMoments = @get 'shiftStartTimesOfDayAsMoments'
    shiftStartTimesOfDayStruct.push { timeAsString: timeAsString, timeAsMoment: shiftStartTimesOfDayAsMoments[i] } for timeAsString, i in @get 'shiftStartTimesOfDayAsStrings'
    shiftStartTimesOfDayStruct
  ).property 'shiftStartTimesOfDayAsStrings', 'shiftStartTimesOfDayAsMoments'

  #############################
  # Shift end time of day
  #############################

  shiftEndTimesOfDayAsMoments: (->
    shiftEndTimesOfDayAsMoments = []
    selectedStartTimeOfDayAsMoment = @get 'selectedStartTimeOfDayAsMoment'
    latestShiftEndTimeOfDayAsMoment = @get 'latestShiftEndTimeOfDayAsMoment'
    shiftMinimumDurationInMinutes = @get 'shiftMinimumDurationInMinutes'
    shiftMaximumDurationInMinutes = @get 'shiftMaximumDurationInMinutes'
    shiftTimeIncrementInMinutes = @get 'shiftTimeIncrementInMinutes'
    nextShiftEndTime = selectedStartTimeOfDayAsMoment.clone().add 'minutes', shiftMinimumDurationInMinutes
    loop
      shiftEndTimesOfDayAsMoments.push nextShiftEndTime
      nextShiftEndTime = nextShiftEndTime.clone().add 'minutes', shiftTimeIncrementInMinutes

      # Exclude end times exceeding latestShiftEndTimeOfDayAsMoment
      break unless nextShiftEndTime.isBefore(latestShiftEndTimeOfDayAsMoment) or nextShiftEndTime.isSame(latestShiftEndTimeOfDayAsMoment, 'minute')

      # Exclude shifts longer than shiftMaximumDurationInMinutes
      break if nextShiftEndTime.diff(selectedStartTimeOfDayAsMoment, 'minutes') > shiftMaximumDurationInMinutes
    shiftEndTimesOfDayAsMoments
  ).property 'selectedStartTimeOfDayAsMoment', 'latestShiftEndTimeOfDayAsMoment', 'shiftMinimumDurationInMinutes', 'shiftTimeIncrementInMinutes'

  shiftEndTimesOfDayAsStrings: (->
    shiftEndTimesOfDayAsStrings = []
    shiftEndTimesOfDayAsStrings.push s.format('h:mma') for s in @get 'shiftEndTimesOfDayAsMoments'
    shiftEndTimesOfDayAsStrings
  ).property 'shiftEndTimesOfDayAsMoments'

  shiftEndTimesOfDayStruct: (-> # contains no new data and only exists to provide a format ingestable by Ember.select
    shiftEndTimesOfDayStruct = []
    shiftEndTimesOfDayAsMoments = @get 'shiftEndTimesOfDayAsMoments'
    shiftEndTimesOfDayStruct.push { timeAsString: timeAsString, timeAsMoment: shiftEndTimesOfDayAsMoments[i] } for timeAsString, i in @get 'shiftEndTimesOfDayAsStrings'
    shiftEndTimesOfDayStruct
  ).property 'shiftEndTimesOfDayAsStrings', 'shiftEndTimesOfDayAsMoments'

  ##############################
  # Shift booking date
  ##############################

  bookingDatesAsMoments: [ # ie today is the soonest you can book, and a week from tomorrow is the latest you can book a shift
    moment().add('days', 0).startOf('day'),
    moment().add('days', 1).startOf('day'),
    moment().add('days', 2).startOf('day'),
    moment().add('days', 3).startOf('day'),
    moment().add('days', 4).startOf('day'),
    moment().add('days', 5).startOf('day'),
    moment().add('days', 6).startOf('day'),
    moment().add('days', 7).startOf('day'),
    moment().add('days', 8).startOf('day')]

  bookingDatesAsStrings: (-> # Wed Jan 21
    bookingDatesAsStrings = []
    bookingDatesAsStrings.push s.format('ddd MMM Do') for s in @get 'bookingDatesAsMoments'

    # START - HACK HACK HACK
    bookingDatesAsStrings[0] = "Today - " + bookingDatesAsStrings[0]
    bookingDatesAsStrings[1] = "Tomorrow - " + bookingDatesAsStrings[1]
    # END - HACK HACK HACK

    bookingDatesAsStrings
  ).property 'bookingDatesAsMoments'
  
  bookingDatesStruct: (-> # contains no new data and only exists to provide a format ingestable by Ember.select
    bookingDatesStruct = []
    bookingDatesAsMoments = @get 'bookingDatesAsMoments'
    bookingDatesStruct.push { dateAsString: dateAsString, dateAsMoment: bookingDatesAsMoments[i] } for dateAsString, i in @get 'bookingDatesAsStrings'
    bookingDatesStruct
  ).property 'bookingDatesAsStrings', 'bookingDatesAsMoments'


  ##############################
  # Current User Selections - keeps track of page state as the user clicks around
  ##############################

  bookSpinnerButtonIsDisabled: null    # default value set in routes/business/book-spinner setupController

  selectedDateAsMoment: null           # default value set in routes/business/book-spinner setupController
  selectedStartTimeOfDayAsMoment: null # default value set in routes/business/book-spinner setupController
  selectedEndTimeOfDayAsMoment: null   # default value set in routes/business/book-spinner setupController

  selectedStartDateAndTimeAsMoment: (->
    selectedStartDateAndTimeAsMoment = @get('selectedStartTimeOfDayAsMoment').clone()
    selectedStartDateAndTimeAsMoment.dayOfYear(@get('selectedDateAsMoment').dayOfYear())
  ).property 'selectedDateAsMoment', 'selectedStartTimeOfDayAsMoment'

  selectedEndDateAndTimeAsMoment: (->
    selectedEndDateAndTimeAsMoment = @get('selectedEndTimeOfDayAsMoment').clone()
    selectedEndDateAndTimeAsMoment.dayOfYear(@get('selectedDateAsMoment').dayOfYear())
  ).property 'selectedDateAsMoment', 'selectedEndTimeOfDayAsMoment'


  ##############################
  # Observers on current selections - keeps the model in sync with current user selections
  ##############################

  shiftEndTimesOfDayAsMomentsChanged: (->
    shiftEndTimesOfDayAsMoments = @get('shiftEndTimesOfDayAsMoments')
    defaultEndTimeOfDay = shiftEndTimesOfDayAsMoments[@get 'defaultShiftEndTimeIndex']
    defaultEndTimeOfDay = shiftEndTimesOfDayAsMoments[shiftEndTimesOfDayAsMoments.length-1] unless defaultEndTimeOfDay
    @set 'selectedEndTimeOfDayAsMoment', defaultEndTimeOfDay
  ).observes 'shiftEndTimesOfDayAsMoments'

`export default controller`
