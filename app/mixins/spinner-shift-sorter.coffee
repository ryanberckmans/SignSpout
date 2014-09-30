`import Ember from 'ember'`

# WARNING: Any object using SpinnerShiftSorterMixin must also use ClockMixin
#          I'd prefer to have SpinnerShiftSorterMixin = ClockMixin.extend, but this functionality isn't provided
#          It was recommended that I use Ember.assert to check for the presence of ClockMixin, but I'm not sure where to put the actual Ember.assert line
SpinnerShiftSorterMixin = Ember.Mixin.create
  unmatchedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.unmatched()
  ).property 'spinnerShifts.@each.state'

  matchedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.matched()
  ).property 'spinnerShifts.@each.state'

  completedShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.completed()
  ).property 'spinnerShifts.@each.state'

  cancelledShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.cancelled()
  ).property 'spinnerShifts.@each.state'

  erroredShifts: (->
    @get('spinnerShifts').filter (spinnerShift) ->
        spinnerShift.errored()
  ).property 'spinnerShifts.@each.state'

  upcomingShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isBefore(moment(spinnerShift.get 'startDateAndTime'))
  ).property 'matchedShifts.@each', 'eachSecond'

  liveShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'startDateAndTime')) && now.isBefore(moment(spinnerShift.get 'endDateAndTime'))
  ).property 'matchedShifts.@each', 'eachSecond'

  postLiveShifts: (->
    now = moment()
    @get('matchedShifts').filter (spinnerShift) ->
      now.isAfter(moment(spinnerShift.get 'endDateAndTime'))
  ).property 'matchedShifts.@each', 'eachSecond'

`export default SpinnerShiftSorterMixin`
