`import Ember from 'ember'`

# Format, for display to user, the day of month of the passed Date object
# Include the year if it differs from the current year
formatDayOfMonth = (date) ->
  now = moment()
  dateMoment = moment(date)
  if now.year() != dateMoment.year()
    dateMoment.format('ddd MMM D YYYY')
  else
    dateMoment.format('ddd MMM D')

FormatDayOfMonthHelper = Ember.Handlebars.makeBoundHelper formatDayOfMonth

`export default FormatDayOfMonthHelper`
