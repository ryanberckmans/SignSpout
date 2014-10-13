`import Ember from 'ember'`

TransitionToUserHomepageRouteMixin = Ember.Mixin.create
  _transitionToUserHomepage: (transition) ->
    if @get 'auth.businessId'
      Ember.Logger.debug 'transitioning to business ' + @get('auth.businessId') + ' homepage for user ' + @get('auth.uid')
      @transitionTo 'business',  @get('auth.businessId')
    else if @get 'auth.spinnerId'
      Ember.Logger.debug 'transitioning to spinner ' + @get('auth.spinnerId') + ' homepage for user ' + @get('auth.uid')
      @transitionTo 'spinner', @get('auth.spinnerId')
    null

  beforeModel: ->
    this._transitionToUserHomepage()

  _TransitionToUserHomepageRouteMixin_IdObserver: (->
    Ember.run.once this, this._transitionToUserHomepage
  ).observes 'auth.businessId', 'auth.spinnerId'

`export default TransitionToUserHomepageRouteMixin`
