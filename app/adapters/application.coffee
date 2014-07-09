`import DS from 'ember-data'`

# Uncomment next line to use fixtures
#adapter = DS.FixtureAdapter.extend()

# Uncomment next lines to use Firebase
adapter = DS.FirebaseAdapter.extend
  firebase: new window.Firebase 'https://' + window.SignSpinnersENV.APP.firebase_instance + '.firebaseio.com'

`export default adapter`
