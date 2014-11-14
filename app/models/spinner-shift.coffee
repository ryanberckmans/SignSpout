`import Ember from 'ember'`
`import DS from 'ember-data'`

STATE_UNMATCHED = "unmatched"
STATE_MATCHED   = "matched"
STATE_COMPLETED = "completed"
STATE_CANCELLED = "cancelled"
STATE_ERROR     = "error"

SpinnerShift = DS.Model.extend
  business: DS.belongsTo 'business', { async:true }
  spinner: DS.belongsTo 'spinner', { async:true }
  startDateAndTime: DS.attr 'date'
  endDateAndTime:   DS.attr 'date'

  # {break,lunch}{Start,End}DateAndTime have no associated functions and should be set directly.
  # Eventually we may want to perform additional validation and create functions such as setBreakTimes( start, end )
  breakStartDateAndTime: DS.attr 'date'
  breakEndDateAndTime:   DS.attr 'date'
  lunchStartDateAndTime: DS.attr 'date'
  lunchEndDateAndTime:   DS.attr 'date'

  state: DS.attr 'string', { defaultValue: STATE_UNMATCHED }
  errorReason: DS.attr 'string' # only defined if state == STATE_ERROR
  spinnerRating: DS.attr 'number' # Integer 1-5 star rating

  # Private. Change this SpinnerShift's state to the passed newState
  # does NOT save() - must be persisted elsewhere
  _change_state: (newState, detail = "(no detail given)") ->
    Ember.Logger.info "SpinnerShift " + @get('id') + " transitioned from state " + @get('state') + " to " + newState + ". Detail: " + detail
    @set 'state', newState
    null
  
  # Private. Transition this SpinnerShift to the error state.
  # DOES save()
  # @return {Promise} resolves when this SpinnerShift has been saved in the error state
  _error: (reason = "(no reason given)") ->
    currentState = @get 'state'
    Ember.Logger.warn "SpinnerShift " + @get('id') + " errored while in state " + currentState + ". Reason: " + reason
    @set 'state', STATE_ERROR
    @set 'errorReason', reason
    _this = this
    @save().catch (reason) ->
      Ember.Logger.error "SpinnerShift " + _this.get('id') + " save() failed on transition to the error state. Rolling back this SpinnerShift. Reason: " + reason
      _this.rollback()
      throw reason

  # Convenience functions to query current state
  unmatched: ->
    @get('state') == STATE_UNMATCHED
  matched: ->
    @get('state') == STATE_MATCHED
  completed: ->
    @get('state') == STATE_COMPLETED
  cancelled: ->
    @get('state') == STATE_CANCELLED
  errored: ->
    @get('state') == STATE_ERROR

  # Set the Spinner for this SpinnerShift. Mutate and save only this SpinnerShift; the Spinner is updated elsewhere.
  # There isn't a corresponding setBusiness because SpinnerShift should always have its business set upon creation.
  # Requires STATE_UNMATCHED or will transition to STATE_ERROR
  # @return {Promise} resolves when the spinner has been set or when state has been set to error
  setSpinner: (spinner) ->
    # Embedding state logic in public action functions isn't a particularly scalable or maintainable way to manage a state machine,
    # However, it is a simple way to start
    unless @get('state') == STATE_UNMATCHED
      return @_error 'attempted to set spinner when state != STATE_UNMATCHED'
    @set 'spinner', spinner
    @_change_state STATE_MATCHED, "matched to spinner " + spinner.get('id')
    _this = this
    @save().catch (reason) ->
      Ember.Logger.error "SpinnerShift " + _this.get('id') + " save() failed on setSpinner with spinner " + spinner.get('id') + ". Rolling back this SpinnerShift. Reason " + reason
      # WARNING - for some reason, _this.rollback() isn't correctly clearing the spinner.. TBD
      _this.rollback()
      throw reason

  # Cancel this shift
  # @return {Promise} resolves when state has been set to cancelled or error
  cancel: ->
    unless @get('state') == STATE_UNMATCHED
      return @_error 'attempted to cancel shift when state != STATE_UNMATCHED'
    @_change_state STATE_CANCELLED, "cancelled shift by calling cancel()"
    _this = this
    @save().catch (reason) ->
      Ember.Logger.error "SpinnerShift " + _this.get('id') + " save() failed on cancel. Rolling back this SpinnerShift. Reason " + reason
      _this.rollback()
      throw reason

  # Set the spinnerRating, expects an integer 1 <= x <= 5 star rating
  # @return {Promise} resolves when the rating has been set or state set to error
  setSpinnerRating: (spinnerRating) ->
    unless @get('state') == STATE_MATCHED
      return @_error 'attempted to set spinner rating when state != STATE_MATCHED'
    unless moment().isAfter(moment(@get 'endDateAndTime'))
      return @_error 'attempted to set spinner rating before shift was over'
    if typeof spinnerRating == 'number'
      Ember.Logger.debug "SpinnerShift " + @get('id') + " received setSpinnerRating " + spinnerRating
      spinnerRating = Math.round(spinnerRating)
      spinnerRating = 1 if spinnerRating < 1
      spinnerRating = 5 if spinnerRating > 5
    else
      return @_error 'attempted to set spinner rating with a non-number'
    @set 'spinnerRating', spinnerRating
    Ember.Logger.info "SpinnerShift " + @get('id') + " set spinnerRating to " + spinnerRating
    @_change_state STATE_COMPLETED, 'completed after spinnerRating was set'
    _this = this
    @save().catch (reason) ->
      Ember.Logger.error "SpinnerShift " + _this.get('id') + " save() failed on setSpinnerRating. Rolling back this SpinnerShift. Reason " + reason
      _this.rollback()
      throw reason

`export default SpinnerShift`
