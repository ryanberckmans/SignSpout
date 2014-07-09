`import DS from 'ember-data'`

SpinnerShift = DS.Model.extend
  business: DS.belongsTo 'business', { async:true }
  spinner: DS.belongsTo 'spinner', { async:true }
  date: DS.attr 'date' # ISO 8601. Example of UTC date-time that is ISO 8601 compliant: "2014-07-16T14:30Z" is July 16th, 2014, at 2:30pm UTC.

`export default SpinnerShift`
