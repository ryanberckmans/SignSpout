import Ember from 'ember';
import config from '../config/environment';

var dbRef = new window.Firebase('https://' + config.firebase_instance + '.firebaseio.com');

// Based on https://gist.github.com/raytiley/8976037
var SignSpinnersAuthentication =  Ember.Object.extend({

  //**********
  // Public
  //**********

  // Public.
  // @return {Boolean} true if the user is authenticated, false otherwise
  isAuthenticated: function() {
    return this.get('_currentUser') !== null;
  }.property('_currentUser'),

  // Public. Authenticated user's email
  email: Ember.computed.oneWay('_currentUser.email'),

  // Public. Authenticated user's uid
  uid:   Ember.computed.oneWay('_currentUser.uid'),

  // Public. Allows a client to delay until authentication state has been synced with the server
  // @return {Promise} resolves when isAuthenticated has been synced with the server
  postInit: function() {
    var logonOnInitPromise = this.get('_loginOnInitPromise');
    if (logonOnInitPromise === null) {
      Ember.Logger.debug("postInit attempting to login an existing session");
      logonOnInitPromise = this.login();
      this.set('_loginOnInitPromise', logonOnInitPromise);
    }
    return logonOnInitPromise;
  }.on('init'),

  // Public.
  // Logs a user in with an email and password.
  // If no arguments are given, attempts to login a currently active session.
  // @return {Promise} resolves true if the login is successful, false otherwise
  login: function(email, password) {
    Ember.Logger.debug("SignSpinnersAuthentication: starting login");
    if (this.get('_currentUser') !== null) {
      Ember.Logger.error('login expected _currentUser to be null');
      return Ember.RSVP.reject('attempted to login when authenticated');
    }

    if (email === undefined) {
      return this._loginActiveSession();
    }
    else {
      return this._loginWithCredentials(email, password);
    }
  },

  // Public.
  // @return {Promise} resolves when the user is logged out.  
  logout: function() {
    Ember.Logger.debug("SignSpinnersAuthentication: starting logout");
    if (this.get('_currentUser') === null) {
      Ember.Logger.error('logout expected _currentUser to exist');
      return Ember.RSVP.reject('attempted to logout when not authenticated');
    }

    var self = this;
    return new Ember.RSVP.Promise(function(resolve, reject) {
      var authClient = new window.FirebaseSimpleLogin(dbRef, function(error, user) {
        Ember.run(function() {
          if (error) {
            reject(error);
          }

          if (!user) {
            Ember.Logger.info('SignSpinnersAuthentication: logged out');
            self.set('_currentUser', null);
            resolve(null);
          }
        });
      });
      authClient.logout();
    });
  },

  // Public.
  // Attempts to create a new user with the passed email and password.
  // If the user is created successfully, the new user is logged in and _currentUser is set.
  // @return {Promise} resolves true if the user is created and logged in, rejects on creation or login error
  createNewUser: function(email, password) {
    Ember.Logger.debug("SignSpinnersAuthentication: starting createNewUser");
    if (this.get('_currentUser') !== null) {
      Ember.Logger.error('createNewUser expected _currentUser to be null');
      return Ember.RSVP.reject('attempted to create new user when authenticated');
    }

    var self = this;
    var promise = new Ember.RSVP.Promise(function(resolve, reject) {
        var authClient = new window.FirebaseSimpleLogin(dbRef, function(error, user) {
          Ember.run(function() {
            if (error) {
              reject(error);
            }

            // ie the created user was successfully logged in
            if (user) {
              // ****
              // **** TBD - Must set authentication data in firebase. Be careful not to set _currentUser until the authentication data exists in Firebase.
              // ****       Observers on _currentUser will expect the logged in user to be fully-formed, ie authentication/$uid exists
              // ****
              self.set('_currentUser', user);
              resolve(user);
            }
          });
        });

        authClient.createUser(email, password, function(error, user) {
          Ember.run(function() {
            if (error) {
              reject(error);
            }

            if (user) {
              authClient.login('password', {email: email, password: password});
            }
          });
        });
    });

    return promise;
  },

  //**********
  // Private
  //**********

  _currentUser: null, // We define "Is the user currently authenticated?" as _currentUser !== null.
  _loginOnInitPromise: null,

  // Attempts to login a new session with the passed email and password, and sets _currentUser if the login is successful
  // @return {Promise} resolves true if the login is successful, false otherwise
  _loginWithCredentials: function(email, password) {
    Ember.Logger.debug("SignSpinnersAuthentication: starting _loginWithCredentials");
    var self = this;
    // Setup a promise that creates the FirebaseSimpleLogin and resolves
    var promise = new Ember.RSVP.Promise(function(resolve, reject) {
      var authClient = new window.FirebaseSimpleLogin(dbRef, function(error, user) {
        //First Time this fires error and user should be null. If connection successful
        //Second Time will be due to login. In that case we should have user or error
        Ember.run(function() {
          // TBD handle every error code - https://www.firebase.com/docs/web/guide/user-auth.html#section-full-error
          if (error && error.code === 'INVALID_USER') {
            resolve(false);
          } else if (error) {
            reject(error);
          }

          if (user) {
            Ember.Logger.info('SignSpinnersAuthentication: logged in with email+password');
            self.set('_currentUser', user);
            resolve(true);
          }
        });
      });
      authClient.login('password', {
            email: email,
            password: password
      });
    });

    return promise;
  },

  /* jshint ignore:start */
  // Attempts to login in an active session, and sets _currentUser if the login is successful
  // @return {Promise} resolves true if the login is successful, false otherwise
  _loginActiveSession: function() {
    Ember.Logger.debug("SignSpinnersAuthentication: starting _loginActiveSession");
    var self = this;
    // Setup a promise that creates the FirebaseSimpleLogin and resolves
    var promise = new Ember.RSVP.Promise(function(resolve, reject) {
      
      var authClient = new window.FirebaseSimpleLogin(dbRef, function(error, user) {
        // This callback should fire just once if no error or user than not logged in
        Ember.run(function() {
          if (!error && !user) {
            Ember.Logger.info('SignSpinnersAuthentication: found no existing session');
            resolve(false);
          }

          if (error) {
            reject(error);
          }

          if (user) {
            Ember.Logger.info('SignSpinnersAuthentication: re-established existing session');
            self.set('_currentUser', user);
            resolve(true);
          }
        });
      });
    });

    return promise;
  }
  /* jshint ignore:end */
});

var SignSpinnersAuthenticationInitializer = {
  name: 'sign-spinners-authentication',

  initialize: function(container, application) {
    application.register('auth:main', SignSpinnersAuthentication);
    application.inject('controller', 'auth', 'auth:main');
    application.inject('route', 'auth', 'auth:main');
  }
};

export default SignSpinnersAuthenticationInitializer;
