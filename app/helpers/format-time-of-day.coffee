`import Ember from 'ember'`

formatTimeOfDay = (dateObject) ->
  moment(dateObject).format('h:mma')

FormatTimeOfDayHelper = Ember.Handlebars.makeBoundHelper formatTimeOfDay

`export default FormatTimeOfDayHelper`
