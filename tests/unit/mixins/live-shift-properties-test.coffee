`import Ember from 'ember'`
`import LiveShiftPropertiesMixin from 'sign-spinners/mixins/live-shift-properties'`

module 'LiveShiftPropertiesMixin'

# Replace this with your real tests.
test 'it works', ->
  LiveShiftPropertiesObject = Ember.Object.extend LiveShiftPropertiesMixin
  subject = LiveShiftPropertiesObject.create()
  ok subject
