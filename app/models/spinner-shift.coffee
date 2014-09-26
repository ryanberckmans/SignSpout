`import Ember from 'ember'`
`import DS from 'ember-data'`

STATE_UNMATCHED = "unmatched"
STATE_MATCHED   = "matched"
STATE_CANCELLED = "cancelled"
STATE_ERROR     = "error"

SpinnerShift = DS.Model.extend
  # Warning, when using belongsTo:hasMany, the belongsTo side must be set BEFORE the hasMany side.
  # Ie, SpinnerShift.belongsTo Business must be set BEFORE Business.hasMany SpinnerShift.
  business: DS.belongsTo 'business', { async:true }
  spinner: DS.belongsTo 'spinner', { async:true }
  startDateAndTime: DS.attr 'date' # ISO 8601. Example of UTC date-time that is ISO 8601 compliant: "2014-07-16T14:30Z" is July 16th, 2014, at 2:30pm UTC.
  endDateAndTime:   DS.attr 'date' # ISO 8601. Example of UTC date-time that is ISO 8601 compliant: "2014-07-16T14:30Z" is July 16th, 2014, at 2:30pm UTC.
  state: DS.attr 'string', { defaultValue: STATE_UNMATCHED }
  errorReason: DS.attr 'string' # only defined if state == STATE_ERROR

  # Private. Change this SpinnerShift's state to the passed newState
  # does NOT save() - must be persisted elsewhere
  _change_state: (newState, detail = "(no detail given)") ->
    Ember.Logger.info "SpinnerShift " + @get('id') + " transitioned from state " + @get('state') + " to " + newState + ". Detail: " + detail
    @set 'state', newState
    null
  
  # Private. Transition this SpinnerShift to the error state.
  # DOES save()
  _error: (reason = "(no reason given)") ->
    currentState = @get 'state'
    Ember.Logger.warn "SpinnerShift " + @get('id') + " errored while in state " + currentState + ". Reason: " + reason
    @set 'state', STATE_ERROR
    @set 'errorReason', reason
    @save()
    null

  # Convenience functions to query current state
  unmatched: ->
    @get('state') == STATE_UNMATCHED
  matched: ->
    @get('state') == STATE_MATCHED
  cancelled: ->
    @get('state') == STATE_CANCELLED
  errored: ->
    @get('state') == STATE_ERROR

  # Set the Spinner for this SpinnerShift. Mutate and save only this SpinnerShift; the Spinner is updated elsewhere.
  # There isn't a corresponding setBusiness because SpinnerShift should always have its business set upon creation.
  # Requires STATE_UNMATCHED or will transition to STATE_ERROR
  setSpinner: (spinner) ->
    # Embedding state logic in public action functions isn't a particularly scalable or maintainable way to manage a state machine,
    # However, it is a simple way to start
    unless @get('state') == STATE_UNMATCHED
      return @_error 'attempted to set spinner when state != STATE_UNMATCHED'
    @set 'spinner', spinner
    @_change_state STATE_MATCHED, "matched to spinner " + spinner.get('id')
    @save()

`export default SpinnerShift`
