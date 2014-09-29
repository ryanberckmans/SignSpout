`import Ember from 'ember'`
`import AuthenticatedRouteMixin from 'sign-spinners/mixins/authenticated-route'`

module 'AuthenticatedRouteMixin'

# Replace this with your real tests.
test 'it works', ->
  AuthenticatedRouteObject = Ember.Object.extend AuthenticatedRouteMixin
  subject = AuthenticatedRouteObject.create()
  ok subject
