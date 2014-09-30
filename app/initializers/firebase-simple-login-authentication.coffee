`import Ember from 'ember'`
`import config from '../config/environment'`

FirebaseSimpleLoginAuthenticator = Ember.Object.extend
  # Public API
  isAuthenticated: false
  email: Ember.computed.oneWay '_firebaseSimpleLoginUserObject.email'
  uid:   Ember.computed.oneWay '_firebaseSimpleLoginUserObject.uid'

  # Public. Ember.RSVP.Promise. authenticationInProgress allows clients to wait for FirebaseSimpleLogin to establish a session before relying on the value of isAuthenticated
  #
  # Explanation:
  #   On init, FirebaseSimpleLogin will attempt to re-establish an existing session, invoking the callback passed to _firebaseSimpleLoginClient
  #   If the user refreshes the page (hits F5) on an authenticated route, isAuthenticated will always be false until the FirebaseSimpleLogin session has been established.
  #   Wait for Promise authenticationInProgress to settle to avoid redirecting when a user is in fact logged in.
  #
  #
  # WARNING - I must look into removing authenticationInProgress, it is a terrible api. Look at https://gist.github.com/raytiley/8976037 which apparently is blessed by stefan
  # Future plans: surfacing authenticationInProgress as a public api is clunky. Perhaps I want to extend PromiseObject.
  #               http://emberjs.com/api/data/classes/DS.PromiseObject.html 
  #               Future client code example (does not apply today):
  #               @get('auth').then -> @get 'auth.isAuthenticated'
  authenticationInProgress: null

  # Private
  _firebaseSimpleLoginClient: null
  _firebaseSimpleLoginUserObject: null  # User object provided by FirebaseSimpleLogin after successful authentication. Set to null upon logout.

  init: ->
    _this = this

    # See above note on authenticationInProgress
    @set 'authenticationInProgress', new Ember.RSVP.Promise (resolve) ->
      _this._firebaseSimpleLoginClient = new window.FirebaseSimpleLogin new window.Firebase('https://' + config.firebase_instance + '.firebaseio.com'), (error, authenticatedUser) ->
        if error
          Ember.Logger.error 'FirebaseSimpleLoginAuthenticator error: ' + error
          # TBD handle every error code - https://www.firebase.com/docs/web/guide/user-auth.html#section-full-error
        else if authenticatedUser
          Ember.Logger.info 'FirebaseSimpleLogin authenticated ' + authenticatedUser.uid + ', provider: ' + authenticatedUser.provider
          _this.set 'isAuthenticated', true
          _this.set '_firebaseSimpleLoginUserObject', authenticatedUser
        else
          Ember.Logger.info 'FirebaseSimpleLogin logged out'
          _this.set 'isAuthenticated', false
          _this.set '_firebaseSimpleLoginUserObject', null
        
        # See above note on authenticationInProgress
        if _this.get 'authenticationInProgress'
          _this.set 'authenticationInProgress', null
          resolve()
    null  

  loginWithEmail: (email, password) ->
    if @get 'isAuthenticated'
      Ember.Logger.error 'expected isAuthenticated to be false on loginWithEmail'
      return
    if @get '_firebaseSimpleLoginUserObject'
      Ember.Logger.error 'expected _firebaseSimpleLoginUserObject to be null on loginWithEmail'
      return
    Ember.Logger.debug 'calling FirebaseSimpleLogin.login with email+password'
    @_firebaseSimpleLoginClient.login 'password', email: email, password: password

  logout: ->
    unless @get 'isAuthenticated'
      Ember.Logger.error 'expected isAuthenticated to be true on logout'
      return
    unless @get '_firebaseSimpleLoginUserObject'
      Ember.Logger.error 'expected _firebaseSimpleLoginUserObject to exist on logout'
      return
    Ember.Logger.debug 'calling FirebaseSimpleLogin.logout'
    @_firebaseSimpleLoginClient.logout()

FirebaseSimpleLoginAuthenticationInitializer =
  name: 'firebase-simple-login-authentication'

  # container, app is passed to initialize - add if you need them (you probably do)
  initialize: (container, application) ->
    application.register 'auth:main', FirebaseSimpleLoginAuthenticator
    application.inject 'controller', 'auth', 'auth:main'
    application.inject 'route', 'auth', 'auth:main'

`export default FirebaseSimpleLoginAuthenticationInitializer`
