`import Ember from 'ember'`

DemoRoute = Ember.Route.extend
  model: ->
    # Set the model to null, however wait for our demo business and spinner to resolve
    Ember.RSVP.all([@store.find('business', 'demo'),
                    @store.find('spinner', 'ryan-berckmans')]).then -> null

  setupController: (controller, model) ->
    @_super(controller, model)
    controller.set 'demoBusiness', @store.getById('business', 'demo')
    controller.set 'demoSpinner', @store.getById('spinner', 'ryan-berckmans')
    Ember.Logger.debug 'DemoRoute: set controller demoBusiness ' + controller.get('demoBusiness') + ', demoSpinner ' + controller.get('demoSpinner')
    null

`export default DemoRoute`
