`import Ember from 'ember'`

AuthenticatedRouteMixin = Ember.Mixin.create
  
  # @return {Promise} returns a Promise which will transition to index as a side effect if the user isn't authenticated
  requireAuthentication: ->
    _this = this    
    @get('auth').postInit().then ->
      if _this.get 'auth.isAuthenticated'
        Ember.Logger.info 'permitting access to route requiring authentication'
      else
        Ember.Logger.info 'transitioning to index due to unauthenticated user'
        _this.transitionTo 'index'
      null

  beforeModel: (transition, queryParams) ->
    @_super transition, queryParams
    return @requireAuthentication()

  actions:
    # TBD - willTransition actually fires when we're _leaving_ this route, without regard for the destination route.
    #       If this route is authenticated, but the new route is unauthenticated, requireAuthentication() will be erroneously triggered
    willTransition: (transition) ->
      @_super transition
      return @requireAuthentication()

    # @param {Controller} - the Controller holding parameters for the login form.
    #                       Expects these properties on the passed controller:
    #                               loginEmail, 
    #                               loginPassword, 
    #                               isLoginButtonDisabled
    #                               loginErrorMessage
    #                       I shouldn't really pass a nested controller up the route chain,
    #                       but this provides an easy way to encapsulate login functionality in AuthenticatedRouteMixin.
    login: (controller)->
      controller.set 'isLoginButtonDisabled', true
      controller.set 'loginErrorMessage', null
      email = controller.get 'loginEmail'
      password = controller.get 'loginPassword'
      controller.set 'loginPassword', null # clear the cached password immediately for security
      email = "" unless email?
      password = "" unless password?
      promise = @get('auth').login(email,password).finally(->
        controller.set 'isLoginButtonDisabled', false
      ).catch (error) ->
        Ember.Logger.debug "login received error: " + error.message
        controller.set 'loginErrorMessage', error.message.replace(/FirebaseSimpleLogin: /, "")
      null

    loginRyan: ->
      @get('auth').login 'ryanberckmans@gmail.com', 'password'

    loginToby: ->
      @get('auth').login 'tobyjonesberckmans@gmail.com', 'toby'

    loginLarry: ->
      @get('auth').login 'larrysgiantsubs@gmail.com', 'larrys'

    logout: ->
      @get('auth').logout()

  _AuthenticatedRouteMixin_isAuthenticatedObserver: (->
    @requireAuthentication()
  ).observes 'auth.isAuthenticated'

`export default AuthenticatedRouteMixin`
