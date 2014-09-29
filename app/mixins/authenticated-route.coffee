`import Ember from 'ember'`

AuthenticatedRouteMixin = Ember.Mixin.create
  requireAuthentication: ->
    unless @get 'auth.isAuthenticated'
      Ember.Logger.info 'transitioning to index due to unauthenticated user'
      @transitionTo 'index'
    Ember.Logger.info 'permitting access to route requiring authentication'

  beforeModel: (transition, queryParams) ->
    @_super transition, queryParams
    _this = this
    if @get 'auth.authenticationInProgress' 
      Ember.Logger.info 'authentication in progress, deferring authentication check'
      @get('auth.authenticationInProgress').then -> _this.requireAuthentication()
    else
      @requireAuthentication()
    null

  actions:
    willTransition: (transition) ->
      @_super transition
      @requireAuthentication()

  isAuthenticatedObserver: (->
    @requireAuthentication()
  ).observes 'auth.isAuthenticated'

`export default AuthenticatedRouteMixin`
