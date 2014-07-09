`import Ember from 'ember'`

ALL_MODELS = ['business', 'spinner', 'spinner-shift']

controller = Ember.Controller.extend  
  actions:
    deleteAllData: ->
      store = this.store
      _helper = (modelName) ->
        promise = store.findAll modelName
        promise.then ->
          promise.forEach (model) ->
            model.destroyRecord()
      _helper modelName for modelName in ALL_MODELS
      
    createTestData: ->
      TEST_DATA = {
        'business': [
          {
            id: "larry's-giant-subs"
            name: "Larry's Giant Subs"
            address: "4479 Deerwood Lake Pkwy #1, Jacksonville, FL 32216"
          }
          { 
            id: "cricket-wireless"
            name: "Cricket Wireless"
            address: "8221 Southside Blvd #13, Jacksonville, FL 32256"
          }
        ]
        'spinner': [
          {
            id: 'ryan-berckmans'
            #spinnerShifts: [2,3]
            firstName: 'Ryan'
            lastName: 'Berckmans'
          }
          {
            id: 'toby'
            #spinnerShifts: [1]
            firstName: 'Toby'
            lastName: 'Jones Berckmans'
          }
        ]
        'spinner-shift': [
          {
            id: 1
            #business: "cricket-wireless"
            #spinner: "toby"
            date: new Date "2014-07-16T14:30Z"
          }
          {
            id: 2
            #business: "cricket-wireless"
            #spinner: "ryan-berckmans"
            date: new Date "2014-07-12T11:30Z"
          }
          {
            id: 3
            #business: "larry's-giant-subs"
            #spinner: "ryan-berckmans"
            date: new Date "2014-07-12T07:30Z"
          }
        ]
      }

      for model in ALL_MODELS
        for data in TEST_DATA[model]
          (this.store.createRecord model, data).save()

      store = this.store
      creatingBusinessAndAssociatedShiftExample = ->
        business = store.createRecord 'business', { id: "fred", name: "fred's fredding" }
        businessPromise = business.save()
        shift = store.createRecord 'spinner-shift', { date: new Date() }
        shiftPromise = shift.save()
        Ember.RSVP.all([businessPromise, shiftPromise]).then ->
          shift.set 'business', business
          shift.save()
          business.get('spinnerShifts').then (spinnerShifts) ->
            spinnerShifts.addObject shift
            business.save()
      #creatingBusinessAndAssociatedShiftExample()

      null
`export default controller`
