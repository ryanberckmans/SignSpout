`import Ember from 'ember'`
`import SpinnerShiftSorterMixin from 'sign-spinners/mixins/spinner-shift-sorter'`

module 'SpinnerShiftSorterMixin'

# Replace this with your real tests.
test 'it works', ->
  SpinnerShiftSorterObject = Ember.Object.extend SpinnerShiftSorterMixin
  subject = SpinnerShiftSorterObject.create()
  ok subject
