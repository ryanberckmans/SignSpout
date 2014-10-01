import Ember from 'ember';
import config from '../config/environment';

var dbRef = new window.Firebase('https://' + config.firebase_instance + '.firebaseio.com');

// Based on https://gist.github.com/raytiley/8976037
var SignSpinnersAuthentication =  Ember.Object.extend({

  // @return {Promise} resolves true if the user is authenticated, false otherwise
  isAuthenticated: function() {
    var _this = this;
    return this.get('_loginOnInitPromise').then(function() { // This promise is created once on init and its result is meaningless when determining if the user is currently authenticated
      return _this.get('currentUser') !== null;
    });
  }.property('currentUser'),

  email: Ember.computed.oneWay 'currentUser.email',
  uid:   Ember.computed.oneWay 'currentUser.uid',

  currentUser: null, // We define "Is the user currently authenticated?" as currentUser !== null.

  // Automatically attempt to re-establish an existing session on init, and use 
  _loginOnInitPromise: null,
  _loginOnInit: function() {
    this.set('_loginOnInitPromise', this.login());
  }.on('init');

  // Logs a user in with an email and password.
  // If no arguments are given, attempts to login a currently active session.
  // @return {Promise} resolves true if the login is successful, false otherwise
  login: function(email, password) {
    if (this.get('currentUser') !== null) {
      Ember.Logger.error('login expected currentUser to be null');
      return Ember.RSVP.reject('attempted to login when authenticated');
    }

    if (email === undefined)
      return this._loginActiveSession();
    else
      return this._loginWithCredentials(email, password);
  },

  // @return {Promise} resolves when the user is logged out.  
  logout: function() {
    if (this.get('currentUser') === null) {
      Ember.Logger.error('logout expected currentUser to exist');
      return Ember.RSVP.reject('attempted to logout when not authenticated');
    }

    var self = this;
    return new Ember.RSVP.Promise(function(resolve, reject) {
      var authClient = new FirebaseSimpleLogin(dbRef, function(error, user) {
        Ember.run(function() {
          if (error) {
            reject(error);
          }

          if (!user) {
            self.set('currentUser', null);
            resolve(null);
          }
        });
      });
      authClient.logout();
    });
  },

  // Attempts to create a new user with the passed email and password.
  // If the user is created successfully, the new user is logged in and currentUser is set.
  // @return {Promise} resolves true if the user is created and logged in, rejects on creation or login error
  createNewUser: function(email, password) {
    if (this.get('currentUser') !== null) {
      Ember.Logger.error('createNewUser expected currentUser to be null');
      return Ember.RSVP.reject('attempted to create new user when authenticated');
    }

    var self = this;
    var promise = new Ember.RSVP.Promise(function(resolve, reject) {
        var authClient = new FirebaseSimpleLogin(dbRef, function(error, user) {
          Ember.run(function() {
            if (error)
              reject(error);

            // ie the created user was successfully logged in
            if (user) {
              // ****
              // **** TBD - Must set authentication data in firebase. Be careful not to set currentUser until the authentication data exists in Firebase.
              // ****       Observers on currentUser will expect the logged in user to be fully-formed, ie authentication/$uid exists
              // ****
              self.set('currentUser', user);
              resolve(user);
            }
          });
        });

        authClient.createUser(email, password, function(error, user) {
          Ember.run(function() {
            if (error)
              reject(error);

            if (user) {
              authClient.login('password', {email: email, password: password});
            }
          });
        });
    });

    return promise;
  },

  // Attempts to login a new session with the passed email and password, and sets currentUser if the login is successful
  // @return {Promise} resolves true if the login is successful, false otherwise
  _loginWithCredentials: function(email, password) {
    var self = this;
    // Setup a promise that creates the FirebaseSimpleLogin and resolves
    var promise = new Ember.RSVP.Promise(function(resolve, reject) {
      var authClient = new FirebaseSimpleLogin(dbRef, function(error, user) {
        //First Time this fires error and user should be null. If connection successful
        //Second Time will be due to login. In that case we should have user or error
        Ember.run(function() {
          // TBD handle every error code - https://www.firebase.com/docs/web/guide/user-auth.html#section-full-error
          if (error && error.code === 'INVALID_USER') {
            resolve(false);
          } else if (error) {
            reject(error)
          }

          if (user) {
            self.set('currentUser', user);
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

  // Attempts to login in an active session, and sets currentUser if the login is successful
  // @return {Promise} resolves true if the login is successful, false otherwise
  _loginActiveSession: function() {
    var self = this;
    // Setup a promise that creates the FirebaseSimpleLogin and resolves
    var promise = new Ember.RSVP.Promise(function(resolve, reject) {
      var authClient = new FirebaseSimpleLogin(dbRef, function(error, user) {
        // This callback should fire just once if no error or user than not logged in
        Ember.run(function() {
          if (!error && !user) {
            resolve(false);
          }

          if (error) {
            reject(error);
          }

          if (user) {
            self.set('currentUser', user);
            resolve(true);
          }
        });
      });
    });

    return promise;
  }
});

var SignSpinnersAuthenticationInitializer = {
  name: 'sign-spinners-authentication',

  initialize: function(container, application) {
    application.register('auth:main', SignSpinnersAuthentication)
    application.inject('controller', 'auth', 'auth:main')
    application.inject('route', 'auth', 'auth:main')
  }
};

export default SignSpinnersAuthenticationInitializer;
