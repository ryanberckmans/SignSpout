`import Ember from 'ember'`

TransitionToUserHomepageRouteMixin = Ember.Mixin.create
  _transitionToUserHomepage: ->
    _this = this
    if @get 'auth.businessId'
      Ember.Logger.debug 'transitioning to business ' + @get('auth.businessId') + ' homepage for user ' + @get('auth.uid')
      this.store.find('business', @get('auth.businessId')).then (business) ->
        _this.transitionTo 'business', business
    else if @get 'auth.spinnerId'
      Ember.Logger.debug 'transitioning to spinner ' + @get('auth.spinnerId') + ' homepage for user ' + @get('auth.uid')
      this.store.find('spinner', @get('auth.spinnerId')).then (spinner) ->
        _this.transitionTo 'spinner', spinner
    null

  beforeModel: (transition) ->
    this._transitionToUserHomepage()

  _TransitionToUserHomepageRouteMixin_IdObserver: (->
    Ember.run.once this, this._transitionToUserHomepage
  ).observes 'auth.businessId', 'auth.spinnerId'

`export default TransitionToUserHomepageRouteMixin`
