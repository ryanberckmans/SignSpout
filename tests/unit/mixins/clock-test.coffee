`import Ember from 'ember'`
`import ClockMixin from 'sign-spinners/mixins/clock'`

module 'ClockMixin'

# Replace this with your real tests.
test 'it works', ->
  ClockObject = Ember.Object.extend ClockMixin
  subject = ClockObject.create()
  ok subject
