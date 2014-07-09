module.exports = (environment) ->
  ENV =
    environment: environment
    baseURL: '/'
    locationType: 'auto'
    EmberENV:
      FEATURES: {}
        # Here you can enable experimental features on an ember canary build
        # e.g. 'with-controller': true

    APP:
      # Here you can pass flags/options to your application instance
      # when it is created
      firebase_instance: 'dazzling-fire-1404' # example 'sweltering-fire-3983'

  if environment == 'development'
    # LOG_MODULE_RESOLVER is needed for pre-1.6.0
    ENV.LOG_MODULE_RESOLVER = true

    ENV.APP.LOG_RESOLVER = true
    ENV.APP.LOG_ACTIVE_GENERATION = true
    ENV.APP.LOG_MODULE_RESOLVER = true
    # ENV.APP.LOG_TRANSITIONS = true
    # ENV.APP.LOG_TRANSITIONS_INTERNAL = true
    ENV.APP.LOG_VIEW_LOOKUPS = true

  if environment == 'production'
    null # placeholder for coffeescript syntax

  ENV
