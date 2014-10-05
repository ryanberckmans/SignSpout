`import Ember from 'ember'`

SpinnerHistoryController = Ember.Controller.extend # Note, this is Controller and not ObjectController because spinner.history has no model
  needs: 'spinner'

`export default SpinnerHistoryController`
