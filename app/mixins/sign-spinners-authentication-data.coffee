`import Ember from 'ember'`
`import config from '../config/environment'`

# SignSpinnersAuthenticationDataMixin is intended to be mixed into SignSpinnersAuthentication
SignSpinnersAuthenticationDataMixin = Ember.Mixin.create
  businessId: null, # authenticated user's businessId, or null if the user isn't authenticated (or if the user's businessId is in fact null)
  spinnerId: null,  # authenticated user's spinnerId,  or null if the user isn't authenticated (or if the user's spinnerId is in fact null)
  
  _businessIdObserver: (->
    _this = this
    this.postInit().then ->
      if _this.get 'isAuthenticated'
        Ember.Logger.debug "SignSpinnersAuthenticationDataMixin: user is authenticated as " + _this.get('uid') + ", retrieving business_id"
        onValueSuccess = (snapshot) ->
          Ember.Logger.debug "SignSpinnersAuthenticationDataMixin: found business_id " + snapshot.val() + " for uid " + _this.get('uid')
          _this.set 'businessId', snapshot.val()

        onValueError = (error) ->
          Ember.Logger.error "SignSpinnersAuthenticationDataMixin: error retrieving business_id for uid " + _this.get('uid') + ". Setting businessId to null. Error: " + error
          _this.set 'businessId', null

        businessIdRef = new window.Firebase('https://' + config.firebase_instance + '.firebaseio.com/authentication/users/' + _this.get('uid') + '/business_id')
        businessIdRef.once 'value', onValueSuccess, onValueError
        null
      else
        Ember.Logger.debug "SignSpinnersAuthenticationDataMixin: user is not authenticated, setting businessId to null."
        _this.set 'businessId', null
    null
  ).observes('isAuthenticated').on 'init'

  _spinnerIdObserver: (->
      _this = this
      this.postInit().then ->
        if _this.get 'isAuthenticated'
          Ember.Logger.debug "SignSpinnersAuthenticationDataMixin: user is authenticated as " + _this.get('uid') + ", retrieving spinner_id"
          onValueSuccess = (snapshot) ->
            Ember.Logger.debug "SignSpinnersAuthenticationDataMixin: found spinner_id " + snapshot.val() + " for uid " + _this.get('uid')
            _this.set 'spinnerId', snapshot.val()

          onValueError = (error) ->
            Ember.Logger.error "SignSpinnersAuthenticationDataMixin: error retrieving spinner_id for uid " + _this.get('uid') + ". Setting spinnerId to null. Error: " + error
            _this.set 'spinnerId', null

          spinnerIdRef = new window.Firebase('https://' + config.firebase_instance + '.firebaseio.com/authentication/users/' + _this.get('uid') + '/spinner_id')
          spinnerIdRef.once 'value', onValueSuccess, onValueError
          null
        else
          Ember.Logger.debug "SignSpinnersAuthenticationDataMixin: user is not authenticated, setting spinnerId to null."
          _this.set 'spinnerId', null
      null
    ).observes('isAuthenticated').on 'init'

`export default SignSpinnersAuthenticationDataMixin`
