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
    willTransition: (transition) ->
      @_super transition
      return @requireAuthentication()

    loginWithEmail: ->
      @get('auth').login 'ryanberckmans@gmail.com', 'password'

    logout: ->
      @get('auth').logout()

  isAuthenticatedObserver: (->
    @requireAuthentication()
  ).observes 'auth.isAuthenticated'

`export default AuthenticatedRouteMixin`
