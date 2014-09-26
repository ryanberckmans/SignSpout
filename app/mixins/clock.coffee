`import Ember from 'ember'`

INTERVAL_IN_MILLISECONDS = 500

ClockMixin = Ember.Mixin.create
  # From http://emberjs.com/guides/cookbook/working_with_objects/continuous_redrawing_of_views/
  
  # Public API, consumer properties should depend on "clock.{eachSecond,eachMinute,eachHour}"
  eachSecond: 0
  eachMinute: 0
  eachHour: 0

  # Private
  _initialTime: moment()
  _intervalCounter: 0
  _tick: (->
    _this = this
    Ember.run.later (->
      now = moment()
      _initialTime = _this.get '_initialTime'
      _this.set 'eachSecond', now.diff(_initialTime, 'seconds')
      _this.set 'eachMinute', now.diff(_initialTime, 'minutes')
      _this.set 'eachHour', now.diff(_initialTime, 'hours')
      _this.incrementProperty '_intervalCounter'
    ), INTERVAL_IN_MILLISECONDS
  ).observes('_intervalCounter').on('init')

`export default ClockMixin`
