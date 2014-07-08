`import DS from 'ember-data'`

SpinnerShift = DS.Model.extend
  business: DS.belongsTo 'business', { async:true }
  durationInMinutes: DS.attr 'number' # Will eventually have some combo of start-time, end-time, etc., for now just duration for luls

SpinnerShift.reopenClass
  FIXTURES: [
    {
      id: 1
      business: "cricket-wireless"
      durationInMinutes: 60
    }
    {
      id: 2
      business: "cricket-wireless"
      durationInMinutes: 180
    }
    {
      id: 3
      business: "larry's-giant-subs"
      durationInMinutes: 270
    }
  ]

`export default SpinnerShift`
