/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    firebase_instance: 'signspout',
    modulePrefix: 'sign-spinners',
    environment: environment,
    baseURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },

    contentSecurityPolicy: {
      'connect-src': "'self' https://auth.firebase.com wss://*.firebaseio.com",
      'script-src': "'self' https://*.firebaseio.com",
      'frame-src': "https://*.firebaseio.com",
      // 'unsafe-inline' is required for eui elements to avoid CSP violations. TODO remove this when I get rid of emberui
      'style-src': "'self' 'unsafe-inline'"
    }
  };

  // 'report-uri' is not POSTing. Tracked as issue #16
  ENV.contentSecurityPolicy['report-uri'] = "https://" + ENV.firebase_instance + ".firebaseio.com/content_security_policy_violations";

  if (environment === 'development') {
    ENV.contentSecurityPolicy['script-src'] = ENV.contentSecurityPolicy['script-src'] + " 'unsafe-eval'";
    // ENV.APP.LOG_RESOLVER = true;
    ENV.APP.LOG_ACTIVE_GENERATION = true;
    ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'auto';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {

  }

  return ENV;
};
