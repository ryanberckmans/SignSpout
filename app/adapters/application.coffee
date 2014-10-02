`import Ember from 'ember'`
`import DS from 'ember-data'`
`import config from '../config/environment'`

# Uncomment next line to use fixtures
#adapter = DS.FixtureAdapter.extend()

# Uncomment next lines to use Firebase
adapter = DS.FirebaseAdapter.extend
  firebase: new window.Firebase 'https://' + config.firebase_instance + '.firebaseio.com'

# POST errors when using Firebase
Ember.onerror = (error) ->
  firebase = new window.Firebase 'https://' + config.firebase_instance + '.firebaseio.com/errors'
  firebase.push
      timestamp: window.Firebase.ServerValue.TIMESTAMP
      stack: error.stack,
      otherInformation: 'exception message'
  throw error

`export default adapter`
