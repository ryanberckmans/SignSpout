`import DS from 'ember-data'`

SpinnerShift = DS.Model.extend
  business: DS.belongsTo 'business', { async:true }
  spinner: DS.belongsTo 'spinner', { async:true } 
  durationInMinutes: DS.attr 'number' # Will eventually have some combo of start-time, end-time, etc., for now just duration for luls

SpinnerShift.reopenClass
  FIXTURES: [
    {
      id: 1
      business: "cricket-wireless"
      spinner: "toby"
      durationInMinutes: 60
    }
    {
      id: 2
      business: "cricket-wireless"
      spinner: "ryan-berckmans"
      durationInMinutes: 180
    }
    {
      id: 3
      business: "larry's-giant-subs"
      spinner: "ryan-berckmans"
      durationInMinutes: 270
    }
  ]

`export default SpinnerShift`
