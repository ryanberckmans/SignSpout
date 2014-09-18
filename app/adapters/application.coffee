`import DS from 'ember-data'`
`import config from '../config/environment'`

# Uncomment next line to use fixtures
#adapter = DS.FixtureAdapter.extend()

# Uncomment next lines to use Firebase
adapter = DS.FirebaseAdapter.extend
  firebase: new window.Firebase 'https://' + config.firebase_instance + '.firebaseio.com'

`export default adapter`
