import Ember from 'ember';
import config from '../config/environment';
import SignSpinnersAuthenticationDataMixin from '../mixins/sign-spinners-authentication-data';

var dbRef = new window.Firebase('https://' + config.firebase_instance + '.firebaseio.com');

// Based on https://gist.github.com/raytiley/8976037
var SignSpinnersAuthentication =  Ember.Object.extend(SignSpinnersAuthenticationDataMixin, {

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
    var promise = this._getFirebaseSimpleLoginPromise();
    this._getFirebaseSimpleLoginClient().logout();
    return promise;
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
    var _this = this;
    var promise = this._getFirebaseSimpleLoginPromise();
    this._getFirebaseSimpleLoginClient().createUser(email, password, function(error, user) {
      Ember.run(function() {
        if (error) {
          _this.get('_firebaseSimpleLoginPromiseReject')(error);
        }
        if (user) {
          // ****       User is created, but firebase/authentication/uid doesn't exist, nor authentication/owned_{businesses,spinners}/{business,spinner}_id              
          // **** TBD - Must set authentication data in firebase. Be careful not to set _currentUser until the authentication data exists in Firebase.
          // ****       Observers on _currentUser will expect the logged in user to be fully-formed, ie authentication/$uid exists
          // ****
          // ****       I should probably create some sort of manual hook here, _userJustCreated(user), so that I can implement my domain logic in SignSpinnersAuthenticationData. And rename this file FirebaseSimpleLoginAuthentication
          _this._getFirebaseSimpleLoginClient().login('password', {email: email, password: password});
        }
      });
    });
    return promise;
  },

  //**********
  // Private
  //**********

  _currentUser: null, // We define "Is the user currently authenticated?" as _currentUser !== null.
  _loginOnInitPromise: null,

  _firebaseSimpleLoginClient: null,
  _firebaseSimpleLoginPromise: null, // Promise used inside FirebaseSimpleLogin callback. Create new for each operation, unless the old promise still exists.
  _firebaseSimpleLoginPromiseResolve: null, // resolve() handler for _firebaseSimpleLoginPromise
  _firebaseSimpleLoginPromiseReject: null,  // reject()  handler for _firebaseSimpleLoginPromise

  // Sets up a new Promise for use inside FirebaseSimpleLogin callback, including a finally() handler to clear this Promise when it has been settled
  // The new promise is set as _firebaseSimpleLoginPromise
  // @return {Promise} for convenience, returns the new Promise, or existing Promise if it hasn't been settled yet
  _getFirebaseSimpleLoginPromise: function() {
    var _this = this;
    var firebaseSimpleLoginPromise = this.get('_firebaseSimpleLoginPromise');
    if (firebaseSimpleLoginPromise === null) {
      firebaseSimpleLoginPromise = new Ember.RSVP.Promise(function(resolve, reject) {
        if (_this.get('_firebaseSimpleLoginPromiseResolve') === null) {
          _this.set('_firebaseSimpleLoginPromiseResolve', resolve);
        } else {
          throw new Error('expected _firebaseSimpleLoginPromiseResolve to be null since _firebaseSimpleLoginPromise is null');
        }
        if (_this.get('_firebaseSimpleLoginPromiseReject') === null) {
          _this.set('_firebaseSimpleLoginPromiseReject', reject);
        } else {
          throw new Error('expected _firebaseSimpleLoginPromiseReject to be null since _firebaseSimpleLoginPromise is null');
        }
      });
      firebaseSimpleLoginPromise.finally(function() {
        // Remove this Promise from this Object when it has been settled - it should be used exactly once in the FirebaseSimpleLogin callback
        // When this finally() handler is invoked, we expect that _firebaseSimpleLoginPromise is still set to this new Promise
        var firebaseSimpleLoginPromise2 = _this.get('_firebaseSimpleLoginPromise');
        if (firebaseSimpleLoginPromise2 !== firebaseSimpleLoginPromise) {
          throw new Error("_firebaseSimpleLoginPromise appears to have been set to a new Promise before the old Promise's finally() handler was invoked");
        }
        _this.set('_firebaseSimpleLoginPromise', null);
        _this.set('_firebaseSimpleLoginPromiseResolve', null);
        _this.set('_firebaseSimpleLoginPromiseReject', null);
        Ember.Logger.debug('cleared _firebaseSimpleLoginPromise');
      });
      Ember.Logger.debug('set new _firebaseSimpleLoginPromise');
      this.set('_firebaseSimpleLoginPromise', firebaseSimpleLoginPromise);
    } else {
      throw new Error("FirebaseSimpleLogin operation already in progress: _firebaseSimpleLoginPromise not null");
    }
    return firebaseSimpleLoginPromise;
  },

  // Must be preceeded with a call to _getFirebaseSimpleLoginPromise(), which sets up a new Promise for use in any FirebaseSimpleLogin operation
  // @return {FirebaseSimpleLogin} singleton client, creating it if necessary
  _getFirebaseSimpleLoginClient: function() {
    var _this = this;
    var firebaseSimpleLoginClient = this.get('_firebaseSimpleLoginClient');
    if (firebaseSimpleLoginClient === null ) {
      Ember.Logger.debug('creating new FirebaseSimpleLogin client');
      firebaseSimpleLoginClient = new window.FirebaseSimpleLogin(dbRef, function(error, user) {
        Ember.run(function() {
          if (error && error.code === 'INVALID_USER') {
            Ember.Logger.warn('SignSpinnersAuthentication: received INVALID_USER');
            _this.get('_firebaseSimpleLoginPromiseResolve')(false);
          } else if (error) {
            _this.get('_firebaseSimpleLoginPromiseReject')(error);
          } else if (!error && !user) {
            Ember.Logger.info('SignSpinnersAuthentication: logged out or found no existing session');
            _this.set('_currentUser', null);
            _this.get('_firebaseSimpleLoginPromiseResolve')(false);
          } else {
            if (!user) {
              throw new Error("expected !null user because boolean algrebra");
            }
            Ember.Logger.info('SignSpinnersAuthentication: re-established existing session');
            _this.set('_currentUser', user);
            _this.get('_firebaseSimpleLoginPromiseResolve')(true);
          }
        });
      });
      this.set('_firebaseSimpleLoginClient', firebaseSimpleLoginClient);
    }
    return firebaseSimpleLoginClient;
  },

  // Attempts to login a new session with the passed email and password, and sets _currentUser if the login is successful
  // @return {Promise} resolves true if the login is successful, false otherwise
  _loginWithCredentials: function(email, password) {
    Ember.Logger.debug("SignSpinnersAuthentication: starting _loginWithCredentials");
    var promise = this._getFirebaseSimpleLoginPromise();
    this._getFirebaseSimpleLoginClient().login('password', {
            email: email,
            password: password});
    return promise;
  },

  // Attempts to login in an active session, and sets _currentUser if the login is successful
  // @return {Promise} resolves true if the login is successful, false otherwise
  _loginActiveSession: function() {
    Ember.Logger.debug("SignSpinnersAuthentication: starting _loginActiveSession");
    var promise = this._getFirebaseSimpleLoginPromise();
    this._getFirebaseSimpleLoginClient(); // initializing the client (if it hasn't already been initialized) is sufficient to login an active session
    return promise;
  }
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
