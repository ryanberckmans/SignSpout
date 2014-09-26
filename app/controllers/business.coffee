`import Ember from 'ember'`
`import ClockMixin from '../mixins/clock'`
`import SpinnerShiftSorterMixin from '../mixins/spinner-shift-sorter'`

BusinessController = Ember.ObjectController.extend ClockMixin, SpinnerShiftSorterMixin
  
`export default BusinessController`
