`import Ember from 'ember'`
`import TransitionToUserHomepageRouteMixin from 'sign-spinners/mixins/transition-to-user-homepage-route'`

module 'TransitionToUserHomepageRouteMixin'

# Replace this with your real tests.
test 'it works', ->
  TransitionToUserHomepageRouteObject = Ember.Object.extend TransitionToUserHomepageRouteMixin
  subject = TransitionToUserHomepageRouteObject.create()
  ok subject
