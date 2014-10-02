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

    loginWithEmail: ->
      @get('auth').login 'ryanberckmans@gmail.com', 'password'

    logout: ->
      @get('auth').logout()

  _AuthenticatedRouteMixin_isAuthenticatedObserver: (->
    @requireAuthentication()
  ).observes 'auth.isAuthenticated'

`export default AuthenticatedRouteMixin`
