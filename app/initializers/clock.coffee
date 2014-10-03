`import Ember from 'ember'`

INTERVAL_IN_MILLISECONDS = 500

Clock = Ember.Object.extend
  # From http://emberjs.com/guides/cookbook/working_with_objects/continuous_redrawing_of_views/
  
  # Public API, consumer properties should depend on "clock.{eachSecond,eachMinute,eachHour}"
  eachSecond: 0
  eachMinute: 0
  eachHour: 0

  # TBD - startOfEach{Minute,Hour} fires not just every minute/hour since Clock was initialized,
  #       but at the start of each real hour/minute, ie at 6:00am startOfEachHour fires,
  #       and at 6:03:00am, startOfEachMinute fires
  startOfEachMinute: null
  startOfEachHour: null

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

ClockInitializer =
  name: 'clock'
  initialize: (container, application) ->
    application.register 'clock:main', Clock
    application.inject 'controller', 'clock', 'clock:main'
    application.inject 'route', 'clock', 'clock:main'

`export default ClockInitializer`
