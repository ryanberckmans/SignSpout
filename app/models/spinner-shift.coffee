`import DS from 'ember-data'`
`import Ember from 'ember'`

SpinnerShift = DS.Model.extend
  # Warning, when using belongsTo:hasMany, the belongsTo side must be set BEFORE the hasMany side.
  # Ie, SpinnerShift.belongsTo Business must be set BEFORE Business.hasMany SpinnerShift.
  business: DS.belongsTo 'business', { async:true }
  spinner: DS.belongsTo 'spinner', { async:true }
  date: DS.attr 'date' # ISO 8601. Example of UTC date-time that is ISO 8601 compliant: "2014-07-16T14:30Z" is July 16th, 2014, at 2:30pm UTC.

  # Set the Spinner for this SpinnerShift. Mutate and save only this SpinnerShift; the Spinner is updated elsewhere.
  # There isn't a corresponding setBusiness because SpinnerShift should always have its business set upon creation.
  setSpinner: (spinner) ->
    this.set 'spinner', spinner
    this.save()

`export default SpinnerShift`
