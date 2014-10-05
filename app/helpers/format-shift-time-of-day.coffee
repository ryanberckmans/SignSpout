`import Ember from 'ember'`

formatShiftTimeOfDay = (spinnerShift) ->
  moment(spinnerShift.get('startDateAndTime')).format('h:mma-') + moment(spinnerShift.get('endDateAndTime')).format('h:mma')

FormatShiftTimeOfDayHelper = Ember.Handlebars.makeBoundHelper formatShiftTimeOfDay

`export default FormatShiftTimeOfDayHelper`
